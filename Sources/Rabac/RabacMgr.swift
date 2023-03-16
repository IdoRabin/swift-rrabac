//
//  Rabac.swift
//
//
//  Created by Ido on 06/2/2023.
//

import Foundation
#if VAPOR
import Vapor
#else
#endif

fileprivate let dlog : DSLogger? = DLog.forClass("Rabac")?.setting(verbose: true)

final public class RabacMgr {
    
    public static var  version : String = "1.0.0"
    public var  version : String  {
        return Self.version
    }
    
    // MARK: Const
    // MARK: Static
    private static let MAX_FIND_LOG_LOADED_RECURSIONS = 16
    private static let DEBUG_SIMULATE_EMPTY_CACHE_FILE = RabacDebug.IS_DEBUG && false
    
    // let title : String
    fileprivate (set) var elements : [RabacID:RabacElement] = [:]
    fileprivate (set) var paramTypes : [String:RabacParameterRecord] = [:]
    // TODO: fileprivate (set) var validationsCache : Cache<String, Bool>(nam)
    
    @SkipEncode var whenLoaded : [(_ error : Error?)->Void] = []
    
    // MARK: Singleton
    public static let shared = RabacMgr()
    private init() {
        #if VAPOR
        dlog?.verbose("\(Self.self).init (Singleton with Vapor)")
        #else
        dlog?.note("\(Self.self).init - Vapor not found! Rabac works best with the NIO Vapor package. Some features are not avaialble without the Vapor framework.")
        #endif
        
        self.registerDefaultParamTypes()
        
        self.notifyWasLoaded(error: nil)
    }
    
    public func shutdown() {
        dlog?.info("\(Self.self) shutdown")
    }
    
    deinit {
        dlog?.info("\(Self.self) deinit")
    }
    
    // MARK: Private
    private func registerDefaultParamTypes() {
        let uid844412 = UUID.REGEX
        self.registerPathParam(keyName: "UID", type: UUID.self, possibleRegexes:   [uid844412])
        self.registerPathParam(keyName: "UUID", type: UUID.self, possibleRegexes:   [uid844412])
        
        // AlsO:
        self.registerPathParam(keyName: "BUID", type:BUID.self, possibleRegexes:  [BUID.REGEX])
    }
    
    private func notifyWasLoaded(error:Error?) {
        for loaded in self.whenLoaded {
            loaded(error)
        }
        self.whenLoaded.removeAll()
    }
    
    /// Reegister a rabac route parameter (Same as a vapor route parameter, with a colon : prefix). This parameter will be searched for when a matcher route searches for RabacRouteComponent.parameter
    /// - Parameters:
    ///   - name: name of the param to register, should be unique among the paranmeters
    ///   - excludingCharachterSet: optional charachter set to rapidly exclude possible matches
    ///   - requiredCharachterSet: optional charachter set to rapidly validate that the paremeter is minimally "valid"
    ///   - possibleRegexes: a few possible regexes to search for in order to minimally "validate" the path component matches at least one of the regexes and thus, is minimaly "valid"
    /// - Returns: true if registered, false if failed to register
    @discardableResult
    private func registerPathParam(keyName:String, type:RabacRouteParamable.Type, excludingCharachterSet:CharacterSet?, requiredCharachterSet:CharacterSet?, possibleRegexes:[String]?, validations:RabacValidations?)->Bool {
        guard keyName.count > 0 else {
            dlog?.note("registerPathParam(..) name is an empty string!")
            return false
        }
        guard !paramTypes.hasKey(keyName) else {
            dlog?.note("registerPathParam(..) param \(keyName) was already registered!")
            return true
        }
        var record : RabacParameterRecord? = nil
        
        if excludingCharachterSet != nil || requiredCharachterSet != nil {
            record = RabacParameterRecord(keyName: keyName, type:type, excludingCharachterSet:excludingCharachterSet, requiredCharachterSet:requiredCharachterSet)
        } else if let possibleRegexes = possibleRegexes {
            record = RabacParameterRecord(keyName: keyName, type:type, possibleRegexes: possibleRegexes)
        } else if let validations = validations {
            record = RabacParameterRecord(keyName: keyName, type:type, validations: validations)
        } else {
            dlog?.note("registerPathParam(..) failed all parameter cases!")
        }
        
        if let record = record {
            paramTypes[keyName] = record
            return true
        }
        
        return false
    }
    
    
    // MARK: Public
    
    // Params - get / check if a param type is registered
    func isIdRegistered(_ id : RabacID)->Bool {
        return elements.hasKey(id)
    }

    // Params - "insert" / register param types
    func registerPathParam(keyName:String, type:RabacRouteParamable.Type, excludingCharachterSet:CharacterSet?, requiredCharachterSet:CharacterSet?) {
        
        StringAnyDictionary.registerType(type)
        
        self.registerPathParam(keyName: keyName, type:type, excludingCharachterSet: excludingCharachterSet, requiredCharachterSet: requiredCharachterSet, possibleRegexes:nil, validations: nil)
    }
    
    func registerPathParam(keyName:String, type:RabacRouteParamable.Type, possibleRegexes:[String]) {
        StringAnyDictionary.registerType(type)
        
        self.registerPathParam(keyName: keyName, type:type, excludingCharachterSet: nil, requiredCharachterSet: nil, possibleRegexes:possibleRegexes, validations: nil)
    }
    
    func registerPathParam(keyName:String, type:RabacRouteParamable.Type, validations:RabacValidations) {
        StringAnyDictionary.registerType(type)
        
        self.registerPathParam(keyName: keyName, type:type, excludingCharachterSet: nil, requiredCharachterSet: nil, possibleRegexes :nil, validations: validations)
    }
    
    @discardableResult
    
    /// Will register a param name to use the same validations as an existing param's validations'.
    /// NOTE: The alias MUST be a unique string amongst all param records.
    /// - Parameters:
    ///   - newKeyName: the alias for the exaisting param validation
    ///   - usesParamRecordKeyedBy: teh existing param key
    /// - Returns: true if the record was found and the alias was successfully registered. Otherwise will return false.
    func registerPathParamAlias(newKeyName:String, usesParamRecordKeyedBy oldKey:String)->Bool {
        guard let existingRecord = paramTypes[oldKey] else {
            dlog?.note("registerPathParamAlias(..) failed finding the existing param validations")
            return false
        }
        
        guard paramTypes[newKeyName] == nil else {
            dlog?.note("registerPathParamAlias(..) failed: the new key '\(newKeyName)' is already in use!")
            return false
        }

        paramTypes[newKeyName] = existingRecord // struct copied
        return true
    }
    
    // Params - validate
    func isPathParamValid(paramTypeStr:String, paramVal:String, fullPath: String)->RabacRouteMatchResult {
        guard let record = self.paramTypes[paramTypeStr] else {
            return .failure(.init(code: .misc_failed_validation, reason: "isPathParamValid(paramTypeStr:...) for \(paramTypeStr) failed finding the record to parse paramVal: \(paramVal)!\n was \(paramTypeStr) registered on init?"))
        }
        
        return record.validate(value: paramVal, fullPath: fullPath)
    }
    
    func getPathParam<T: RabacRouteParamable>(paramTypeStr:String, paramVal:String, fullPath: String)->T? {
        guard let record = self.paramTypes[paramTypeStr] else {
            dlog?.note("getPathParam(paramTypeStr:...) for \(paramTypeStr) failed finding the record to parse paramVal: \(paramVal)")
            return nil
        }
        
        return record.parse(value: paramVal, fullPath: fullPath)
    }
    
    #if VAPOR
    func getPathParam<T>(req:Request, routeParamKey:String, type:Type.self)->T? {
        var result : T? = nil
        guard let int = req.parameters.get(paramTypeStr, as: type) else {
            throw Abort(.badRequest)
        }
        return result
    }
    #endif
}

