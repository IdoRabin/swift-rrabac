//
//  Logger.swift
//  testSwift
//
//  Created by Ido Rabin for  on 30/10/2022.
//  Copyright © 2022 Ido Rabin. All rights reserved.
//

// ❌ ❗👁 ⚠️️ ▶ ✘ ✔

import Foundation

public enum DLogLevel : String {
    
    case info
    case success
    case fail
    case note
    case warning
    case todo
    case raisePrecondition
    case assertFailure
    case verbose
}

public typealias DLogKeys = Array<String>
public typealias DLogFilterSet = Set<String>

/// Logger class
public final class DSLogger {
    
    static var IS_LOGS_ENABLED = true // Set according to DEBUG / TEST / Production environment etc..
    static var IS_DETAILS_ENABLED = true
    
    // MARK: types
    public typealias Completion = (_ didOccur:Bool)->Void
    public typealias ExpectedItem = (string:String, step:Int, completion: Completion?)
    
    // MARK: Testing static members
    private static let MAX_CACHE_SIZE = 32
    private static let MAX_EXPECT_WAIT = 32
    private static var expectStepCounter : Int = 0
    private static var stringsToExpect: [ExpectedItem] = []
    private static var filterOut:DLogFilterSet = [DLogLevel.verbose.rawValue] // When empty, all logs are output, otherwise, keys that are included are logged out
    private static var filterIn:DLogFilterSet = [] // When empty, all logs are output, otherwise, keys that are included are the only ones output - this takes precedence over filterOut
    private static var alwaysPrinted:[DLogLevel] = [.warning, .fail, .raisePrecondition, .note] // Will allow printing even when filtered out using filter
    
    // MARK: Private date stamp
    private static let dateFormatter = DateFormatter()
    private let keys:DLogKeys
    private var _isForceVerbose = false
    
    // MARK: Private indent level
    private var _indentLevel : Int = 0
    fileprivate var indentLevel : Int {
        get {
            return _indentLevel
        }
        set {
            _indentLevel = min(max(newValue, 0), 16)
        }
    }
    private var _isVerboseAllowed = false
    private var isVerboseAllowed : Bool {
        get {
            return _isVerboseAllowed
        }
        set {
            _isVerboseAllowed = newValue
        }
    }
    
    // MARK: Testing
    init(keys:DLogKeys) {
        DSLogger.dateFormatter.dateFormat = "HH:mm:ss.SSS"
        self.keys = keys.uniqueElements()
    }
    
    
    /// Settings method which returns self for chaining, allows init().setting(...) in a one-liner
    /// - Parameter verbose: will this instance of DSLogger allow verbose level logs
    /// - Returns: self instance of DSLogger for convenient chaining on init
    /// Example:
    /// fileprivate let dlog : DSLogger? = DLog.forClass("MyClass")?.setting(verbose: true)
    func setting(verbose:Bool = false)->DSLogger {
        self.isVerboseAllowed = verbose
        return self
    }
    
    /// Add log (string) keys into the filter, only these keys will be logged from now on
    ///
    /// - Parameter keys: keys to filter (only these will be printed into log, unless in .alwaysPrinted array)
    public static func filterOnlyKeys(_ keys:DLogKeys) {
        filterIn.formUnion(keys)
    }
    
    /// Remove log (string) keys from the filter, these keys will not be able to log from now on
    ///
    /// - Parameter keys: keys to unfilter (will note be printed into log)
    public static func unfilterOnlyKeys(_ keys:DLogKeys) {
        filterIn.subtract(keys)
    }
    
    /// Add log (string) keys into the filter, these keys will not be logged from now on
    ///
    /// - Parameter keys: keys to filter (will not be printed into log, unless in .alwaysPrinted array
    public static func filterOutKeys(_ keys:DLogKeys) {
        filterOut.formUnion(keys)
    }
    
    /// Remove log (string) keys from the filter, these keys will be able to log from now on
    ///
    /// - Parameter keys: keys to unfilter (will be printed into log)
    public static func unfilterOutKeys(_ keys:DLogKeys) {
        filterOut.subtract(keys)
    }
    
    /// Supress log calls containing the given string for the near future log calls
    ///
    /// The function saves the string to expect for MAX_CACHE_SIZE_CALLS.
    /// The function is used to catch future logs
    /// If during these series of calls the string expected did occur, the logging will be surpressed (ignored)
    /// - Parameter containedString: the string for the logging mechanism to ignore in the next x expected log calls
    public func testingIgnore(containedString:String) {
        #if TESTING
            // Add new completion to see if it will be called in the future
            DSLogger.stringsToExpect.append((text: containedString, step:DSLogger.expectStepCounter, completion:nil))
            
            if (DSLogger.stringsToExpect.count > DSLogger.MAX_CACHE_SIZE) {
                // Pop oldest completion as failed
                let older = DSLogger.stringsToExpect.remove(at: 0)
                if let acompletion = older.completion {
                    acompletion(false)
                }
            }
        #endif
    }
    
    /// The function will call a given completion block when the specified string is logged
    ///
    /// The function saves the string to expect for MAX_CACHE_SIZE_CALLS.
    /// The function is used to catch future logs
    /// If during these series of calls the string expected did occur, will call the completionBlock with true and will surpress the original log
    /// If during these series of calls the string expected did not occur, will call the completionBlock with false
    /// - Parameters:
    ///   - containedString: the string to look for in future log calls
    ///   - completion: the completion block to call when the string is encountered in a log call
    public func testingExpect(containedString:String, completion: @escaping Completion) {
        #if TESTING
            // Add new completion to see if it will be called in the future
            DSLogger.stringsToExpect.append((text: containedString, step:DSLogger.expectStepCounter, completion:completion))
            
            if (DSLogger.stringsToExpect.count > DSLogger.MAX_CACHE_SIZE) {
                // Pop oldest completion as failed
                let older = DSLogger.stringsToExpect.remove(at: 0)
                if let acompletion = older.completion {
                    acompletion(false)
                }
            }
        #endif
    }
    
    /// Clears all future loggin testing expectations without logging or calling expecation completions
    /// The function is used to catch future logs
    public func clearTestingExpectations() {
        DSLogger.expectStepCounter = 0
        DSLogger.stringsToExpect.removeAll()
    }
    
    private func isShouldPrintLog(level: DLogLevel)->Bool {
        guard Self.IS_LOGS_ENABLED else {
            return true
        }
        
        // Will always allow log for items of the given levels
        if DSLogger.alwaysPrinted.contains(level) {
            return true
        }
        
        // Will fiter items based on their existance in the filter
        // When the filter is empty, will log all items
        if DSLogger.filterIn.count > 0 {
            // When our log message has a key in common with filterIn, it should log
            return DSLogger.filterIn.intersection(self.keys).count > 0
        } else if DSLogger.filterOut.count > 0 {
            // When our log message has a key in common with filterOut, it should NOT log
            return DSLogger.filterOut.intersection(self.keys).count == 0
        } else {
            return true
        }
        
        // Will not log this line
        // WILL NEVER BE EXECUTED // return false
    }
    
    /// Determine if a log is to be printed out or surpressed, passed to the testing expect system
    /// For private use (internal to this class)
    private func isShouldSurpressLog(level: DLogLevel, string:String)->Bool {
        guard Self.IS_LOGS_ENABLED else {
            return true
        }
        
        var result = false
        
        #if TESTING
            let stringsToExpect = DSLogger.stringsToExpect
            if (stringsToExpect.count > 0) {
                // Search if any expected srting is part of the given log string
                var foundIndex : Int? = nil
                var itemsToFail:[Int] = []
                
                for (index, item) in stringsToExpect.enumerated() {
                    if text.contains(item.text) {
                        // Found an expected string contained in the given log
                        foundIndex = index
                    }
                    
                    if (DSLogger.expectStepCounter - item.step > DSLogger.MAX_EXPECT_WAIT) {
                        itemsToFail.append(index)
                    }
                }
                
                if let index = foundIndex {
                    // We remove the expected string from the waiting list
                    let item = DSLogger.stringsToExpect.remove(at: index)
                    
                    // We call the expected string with a completion
                    if let acompletion = item.completion {
                        acompletion(true)
                    }
                    
                    result = true
                }
                
                for index in itemsToFail {
                    // We remove the expected string from the waiting list
                    let item = DSLogger.stringsToExpect.remove(at: index)
                    
                    // We call the expected string with a completion
                    if let acompletion = item.completion {
                        acompletion(false)
                    }
                }
            }
            
            DSLogger.expectStepCounter += 1
        #endif
        
        // Print w/ filter
        if self.isShouldPrintLog(level: level) == false {
            result = true
        }
        
        return result // wehn not testing, should not supress log?
    }
    
    // MARK: Private
    
    private func logLineHeader()->String {
        return DSLogger.dateFormatter.string(from: Date()) + " | [" + self.keys.joined(separator: ".") + "] "
    }
    
    private func println(_ str: String) {
        let arr : [String] = str.components(separatedBy: "\n")
        for s in arr {
            //NSLog(s)
            print(logLineHeader() + s.trimmingCharacters(in: ["\""]))
        }
    }
    
    private func debugPrintln(_ str: String)  {
        let arr : [String] = str.components(separatedBy: "\n")
        for s in arr {
            //NSLog(s)
            print(logLineHeader() + s.trimmingCharacters(in: ["\""]))
        }
    }
    
    private func stringFromAny(_ value:Any?) -> String {
        
        if let nonNil = value, !(nonNil is NSNull) {
            
            return String(describing: nonNil)
        }
        
        return ""
    }
    
    /// Log items as an informative log call
    ///
    /// - Parameters:
    ///   - items: Items to log
    ///   - indent: indent level
    public func infoWithIndent(_ items: String, indent: Int) {
        if (!isShouldSurpressLog(level:.info, string: items)) {
            debugPrintln(String(repeating: " ", count: indent) + items)
        }
    }
    
    /// Log items as an informative log call
    /// indent level is 0
    ///
    /// - Parameters:
    ///   - items: Items to log
    public func info(_ items: String) {
        self.infoWithIndent(items, indent: 0)
    }
    
    /// Log items as a "success" log call. Will prefix a for section:checkmark (✔) before the logged string.
    ///
    /// - Parameter items: Items to log
    public func success(_ items: String) {
        if (!isShouldSurpressLog(level:.success, string: items)) {
            debugPrintln("✔ \(items)")
        }
    }
    
    /// Log items as a "fail" log call. Will prefix a red x mark (✘) before the logged string.
    ///
    /// - Parameter items: Items to log
    public func fail(_ items: String) {
        if (!isShouldSurpressLog(level:.fail, string: items)) {
            debugPrintln("✘ \(items)")
        }
    }
    
    public func successOrFail(condition:Bool,_ items: String) {
        if condition {
            success(items)
        } else {
            fail(items)
        }
    }
    
    public func successOrFail(condition:Bool, succStr: String, failStr:String) {
        if condition {
            success(succStr)
        } else {
            fail(failStr)
        }
    }
    /// Log items as a "note" log call. Will prefix an orange warning sign (⚠️️) before the logged string.
    ///
    /// - Parameter items: Items to log
    public func note(_ items: String) {
        if (!isShouldSurpressLog(level:.note, string: items)) {
            debugPrintln("⚠️️ \(items)")
        }
    }
    
    /// Log items as a "todo" log call. Will prefix with a TODO: (👁 TODO:) before the logged string.
    ///
    /// - Parameter items: Items to log
    public func todo(_ items: String) {
        if (!isShouldSurpressLog(level:.note, string: items)) {
            debugPrintln("👁 TODO: \(items)")
        }
    }

    /// Log items as a "warning" log call. Will prefix a red exclemation mark (❗) before the logged string.
    ///
    /// - Parameter items: Items to log
    public func warning(_ items: String) {
        if (!isShouldSurpressLog(level:.warning, string: items)) {
            println("❗ \(items)")
        }
    }
    
    /// Log items as a "raisePreconditionFailure" log call. Will prefix a big red X mark (❌) before the logged string.
    /// Will first log and only then raise the precondition failure
    ///
    /// - Parameter items: Items to log.
    public func raisePreconditionFailure(_ items: @autoclosure ()->String) {
        if (!isShouldSurpressLog(level:.raisePrecondition , string: items())) {
            println("❌ \(items())")
            preconditionFailure("DLog.fatal: \(items())")
        }
    }
    
    
    /// Log items as a "raiseAssertFailure" log call. Will prefix a big red X mark (❌) before the logged string.
    /// Will first log and only then raise the assertion failure
    ///
    /// - Parameter items: Items to log
    public func raiseAssertFailure(_ items: @autoclosure ()->String) {
        if (!isShouldSurpressLog(level:.assertFailure , string: items())) {
            println("❌ \(items())")
            assertionFailure("DLog.assert failed: \(items())")
        }
    }
    
    ///
    ///
    /// - Parameter items: Items to log
    
    
    
    /// Log items as a "verbose" log call. Will prefix with an emoji ( ▶ ) and the word "verbose: " before the logged string.
    /// - Parameters:
    ///   - log: log more: .verbose or .info will add a ▶ verbose prefix, and the other modes will add prefixes where the right arrow is replaced with the log's emoji, for example verbose ⚠️️ | prefix for .note
    ///   - items: Items to log
    public func verbose(log:DLogLevel = .verbose, _ items: String) {
        if self.isVerboseAllowed && !isShouldSurpressLog(level:.verbose, string: items) {
            var mark = " "
            switch log {
            case .info: break; // adds nothing
            case .success: mark += "✔"
            case .fail: mark += "✘"
            case .note: mark += "⚠️️"
            case .warning: mark += "❗"
            case .todo: mark += "👁"
            case .raisePrecondition: mark += "❌"
            case .assertFailure: mark += "❌"
            case .verbose:
                mark = ""
                break // adds nothing
            }
            if mark.count > 0 { mark = " " + mark + " |" }
            debugPrintln("▶ verbose\(mark) \(items)")
        }
    }
    
    // Wrapper
    public var isVerboseActive : Bool {
        return self.isVerboseAllowed
    }
}

/// Logger utility for swift
public enum DLog : String {
    
    static var IS_LOGS_ENABLED : Bool {
        return DSLogger.IS_LOGS_ENABLED
    }
    static var IS_DETAILS_ENABLED : Bool {
        return DSLogger.IS_DETAILS_ENABLED
    }
    
    var IS_LOGS_ENABLED : Bool {
        return Self.IS_LOGS_ENABLED
    }
    var IS_DETAILS_ENABLED : Bool {
        return Self.IS_DETAILS_ENABLED
    }
    
    // Basic activity
    case appDelegate = "appDelegate"
    case misc = "misc"
    case ui = "ui"
    case db = "db"
    case util = "util"
    case accounts = "accounts"
    case api = "api"
    case url = "url"
    case settings = "settings"
    
    // Testing
    case testing = "testing"
    
    // MARK: Public logging functions
    private static var instances : [String:DSLogger] = [:]
    private static var instancesLock = NSRecursiveLock()
    
    static private func instance(keys : DLogKeys, handle:(_ instance: DSLogger)->Void) {
        let key = keys.joined(separator: ".")
        instancesLock.lock {
            if let instance = DLog.instances[key] {
                handle(instance)
            } else {
                let instance = DSLogger(keys: keys)
                DLog.instances[key] = instance
                handle(instance)
            }
        }
    }
    
    static private func instance(key : String, handle:(_ instance: DSLogger)->Void) {
        DLog.instance(keys: [key], handle:handle)
    }
    
    static public func detailOrEmpty(_ items: String)->String {
        return self.IS_DETAILS_ENABLED ? items : ""
    }
    
    public func info(_ items: String, indent: Int = 0) {
        DLog.instance(key: self.rawValue) { (instance) in
            instance.info(items)
        }
    }
    
    public func success(_ items: String) {
        DLog.instance(key: self.rawValue) { (instance) in
            instance.success(items)
        }
    }
    
    public func fail(_ items: String) {
        DLog.instance(key: self.rawValue) { (instance) in
            instance.fail(items)
        }
    }
    
    public func note(_ items: String) {
        DLog.instance(key: self.rawValue) { (instance) in
            instance.note(items)
        }
    }
    
    public func todo(_ items: String) {
        DLog.instance(key: self.rawValue) { (instance) in
            instance.todo(items)
        }
    }
    
    public func verbose(_ items: String) {
        DLog.instance(key: self.rawValue) { (instance) in
            instance.verbose(items)
        }
    }
    
    /// Log items as a "warning" log call. Will prefix a red exclemation mark (❗) before the logged string.
    ///
    /// - Parameter items: Items to log
    public func warning(_ items: String) {
        DLog.instance(key: self.rawValue) { (instance) in
            instance.warning(items)
        }
    }
    
    /// Log items as a "raisePreconditionFailure" log call. Will prefix a big red X mark (❌) before the logged string.
    ///
    /// - Parameter items: Items to log
    public func raisePreconditionFailure(_ items: @autoclosure ()->String) {
        DLog.instance(key: self.rawValue) { (instance) in
            instance.raisePreconditionFailure(items())
        }
    }
    
    public func raiseAssertFailure(_ items: @autoclosure ()->String) {
        DLog.instance(key: self.rawValue) { (instance) in
            instance.raiseAssertFailure(items())
        }
    }
    
    public static func info(_ items: String, indent: Int = 0) {
        DLog.instance(key: "*") { (instance) in
            instance.infoWithIndent(items, indent: indent)
        }
    }
    
    public static func success(_ items: String) {
        DLog.instance(key: "*") { (instance) in
            instance.success(items)
        }
    }
    
    public static func fail(_ items: String) {
        DLog.instance(key: "*") { (instance) in
            instance.fail(items)
        }
    }
    
    public static func note(_ items: String) {
        DLog.instance(key: "*") { (instance) in
            instance.note(items)
        }
    }
    
    public static func todo(_ items: String) {
        DLog.instance(key: "*") { (instance) in
            instance.todo(items)
        }
    }
    
    public static func warning(_ items: String) {
        DLog.instance(key: "*") { (instance) in
            instance.warning(items)
        }
    }
    
    public static func raisePreconditionFailure(_ items: String) {
        DLog.instance(key: "*") { (instance) in
            instance.raisePreconditionFailure(items)
        }
    }
    
    public static func raiseAssertFailure(_ items: String) {
        DLog.instance(key: "*") { (instance) in
            instance.raiseAssertFailure(items)
        }
    }
    
    public static func filterKeys(_ keys:DLogKeys) {
        DSLogger.filterOutKeys(keys)
    }
    
    public static func unfilterKeys(_ keys:DLogKeys) {
        DSLogger.unfilterOutKeys(keys)
    }
    
    public static func forClass(_ name:String)->DSLogger? {
        guard DSLogger.IS_LOGS_ENABLED else {
            return nil
        }
        
        var result : DSLogger? = nil
        DLog.instance(key: name) { (instance) in
            result = instance
        }
        
        // TODO: Not thread safe:
        return result
    }
    
    public static func forKeys(_ keys:String...)->DSLogger? {
        guard DSLogger.IS_LOGS_ENABLED else {
            return nil
        }
        
        var result : DSLogger? = nil
        DLog.instance(keys: keys) { (instance) in
            result = instance
        }
        
        // TODO: Not thread safe:
        return result
    }
    
    public subscript(keys : String...) -> DSLogger? {
        get {
            guard DSLogger.IS_LOGS_ENABLED else {
                return nil
            }
            
            var allKeys : [String] = [self.rawValue]
            allKeys.append(contentsOf: keys)
            
            // TODO: Not thread safe:
            return DLog.forKeys(allKeys.joined(separator: "."))
        }
    }
    
    // MARK: Indents
    static func indentedBlock(logger:DSLogger?, _ block:()->Void) {
        logger?.indentLevel += 1
        block()
        logger?.indentLevel -= 1
    }
    
    static func indentStart(logger:DSLogger?) {
        logger?.indentLevel += 1
    }
    
    static func indentEnd(logger:DSLogger?) {
        logger?.indentLevel -= 1
    }
}
