//
//  Asyncable.swift
//  
//
//  Created by Ido on 15/03/2023.
//

import Foundation

fileprivate let dlog : DSLogger? = DLog.forClass("Asyncable")

/// Asynchroneous execution options for debouncing: Determines if which of the subsequenct calls will be executed and when:
/// - Parameters:
/// - .execFirstCall: the debounce mechanism will call the first call made *after* the "bounce" period began, but only when the timeout is over. All other calls made in hte debounce period are discarderd
///
/// - .execAllCalls: the debounce mechanism will call all the calls made *after* the "bounce" period began, but only when the timeout is over. Will execute all of them by order in one runloop call.
///
/// - .execLastCall: the debounce mechanism will call only the last call made *after* the "bounce" period began, but only when the timeout is over. All preceeding calls withing the debounce period are discarded ano not called.
///
enum AsyncExecOption {
    case execFirstCall
    case execAllCalls
    case execLastCall
}

enum AsyncOnceOption : Int {
    case token = 1
    case instance
    case session
    case install

    var asString : String {
        switch self {
        case .token:        return ".token"
        case .instance:     return ".instance"
        case .session:      return ".session"
        case .install:      return ".install"
        }
    }
}

struct AsyncToken : LosslessStringConvertible {
    
    private _option : AsyncOnceOption = .token
    private _token : String
    
    // MARK: Lifecycle
    fileprivate init(type:AsyncOnceOption, token:String) {
        _option = type
        _token = token
    }
    
    // MARK: LosslessStringConvertible
    var description: String {
        return "\(self._option.asString)_\(_token)"
    }
}

protocol AsyncableExecutor { /* intentionally empty */ }

/// Protocol allowing wrapping convenience async mechanisms regardless of the infrastructure used (GDC, Threads, NIO EventLoopPromise, tasks etc..)
protocol Asyncable {
    
    func performAfter(delay:TimeInterval, block:@escaping ()->Void)
    
    func performOnce(uniqueToken: String, persistSessions:Bool, block:()->Void)->Bool
    func performOncePerInstance(_ instance:Any, block:()->Void)->Bool
    func performOncePerSession(block:()->Void)->Bool
    func performOncePerInstall(token:String, forAnyQueue:Bool, isDebugIgnore:Bool, block:()->Void)->Bool
    
    // debounce
    func debounce(delay:TimeInterval, uniqueKey:String?, execOption:AsyncExecOption, block:@escaping ()->Void)
    
    
}

protocol AsyncablePerformancreTokenCache {
    func isTokenExists(token:String)->Bool
    func setToken(token:String,)
    func clearToken(token:String)->Bool
    func clearAllPerInstance()
    func clearAllPerSession()
    func clearAllPerInstall()
    func clearAll(perInstances:Bool, perSessions:Bool, perInstalls:Bool)
}
    
extension Asyncable /* default inplementation */ {
    func wasPermformedOnce(token:String)->Bool {
        
    }
}

enum AsyncableMode {
    case NIO
    case GDC
    
    public static var currentMode : AsyncableMode {
        #if VAPOR
        return .NIO
        #else
        return .GDC
        #endif
    }
    
    public static var current : AsyncableExecutor {
        
        switch Self.currentMode {
        case .NIO:
            #if VAPOR
            return NIOAsync.shared
            #else
            dlog?.warning("AsyncableExecutor current failed with NIO but VAPOR is not an env validable?")
            fallthrough
            #endif
        case .GDC: 
            return GDCAsync.shared
        }
    }
}
