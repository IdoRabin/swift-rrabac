//
//  RabacParameterRecord.swift
//  
//
//  Created by Ido on 12/03/2023.
//

import Foundation

fileprivate let dlog : DSLogger? = DLog.forClass("RabacParameterRecord")?.setting(verbose: true)

typealias RabacValidationBlock = (_ param:String, _ fullPath:String)->Bool // Not-codable!
typealias RabacValidations = [RabacValidationBlock] // non-codable!

protocol RabacRouteParamable : LosslessStringConvertible & Codable {}

struct RabacParameterRecord : Codable {
    // MARK: Const
    // MARK: Static
    // MARK: Properties / members
    let type : RabacRouteParamable.Type
    let keyName : String
    let excludingCharachterSet:CharacterSet?
    let requiredCharachterSet:CharacterSet?
    let possibleRegexes:[String]? // validation passes if even one regex test passes
    let validations : RabacValidations?
    let validationsReq : ValidationsRequired
    
    enum ValidationsRequired : Codable, Equatable {
        case allValid
        case atLeastSomeValid(Int) // At least
        case atLeastOneValid
    }
    
    // MARK: Private
    enum CodingKeys: CodingKey {
        case type
        case keyName
        case excludingCharachterSet
        case requiredCharachterSet
        case possibleRegexes
        case validations
        case validationsReq
    }
    
    // MARK: Lifecycle
    
    /// Init param record
    /// - Parameters:
    ///   - keyName: param key name
    ///   - type:any type that conforms to RabacRouteParamable and is expected to be the type creating an instance from this parameter eventually (for instance: UUID.self is the type for a parameter that is expected to be a uuid string
    ///   - possibleRegexes: possibleRegexes - validation passes if *even one* regex has a match
    init(keyName:String, type:RabacRouteParamable.Type, possibleRegexes:[String]) {
        self.type = type
        self.keyName = keyName
        self.possibleRegexes = possibleRegexes  // validation passes if even one regex test passes
        self.excludingCharachterSet = nil
        self.requiredCharachterSet = nil
        self.validations = nil
        self.validationsReq = .allValid
    }
    
    init(keyName:String, type:RabacRouteParamable.Type, excludingCharachterSet:CharacterSet?, requiredCharachterSet:CharacterSet?) {
        self.type = type
        self.keyName = keyName
        self.possibleRegexes = nil
        self.excludingCharachterSet = excludingCharachterSet
        self.requiredCharachterSet = requiredCharachterSet
        self.validations = nil
        self.validationsReq = .allValid
    }
    
    init(keyName:String, type:RabacRouteParamable.Type, validations:RabacValidations, validationRequired:ValidationsRequired = .allValid) {
        self.type = type
        self.keyName = keyName
        self.possibleRegexes = nil
        self.excludingCharachterSet = nil
        self.requiredCharachterSet = nil
        self.validations = validations
        self.validationsReq = .allValid
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.keyName = try  container.decode(String.self, forKey:.keyName)
        let typeName = try container.decode(String.self, forKey: .type)
        if let typ = StringAnyDictionary.getType(typeName: typeName)?.type {
            if let typ = typ as? RabacRouteParamable.Type {
                self.type = typ // we make sure the type also conforms to RabacRouteParamable
            } else {
                throw RabacError(code: .misc_failed_decoding, reason: "RabacParameterRecord failed" + (RabacDebug.IS_DEBUG ? " type  \(typeName) needs to conform to RabacRouteParamable." : ""))
            }
        } else {
            throw RabacError(code: .misc_failed_decoding, reason: "RabacParameterRecord failed" + (RabacDebug.IS_DEBUG ? " to load the type from typeName. Was it registered on init?" : ""))
        }
        
        self.excludingCharachterSet = try  container.decodeIfPresent(CharacterSet.self, forKey: .excludingCharachterSet)
        self.requiredCharachterSet = try  container.decodeIfPresent(CharacterSet.self, forKey: .requiredCharachterSet)
        self.possibleRegexes = try  container.decodeIfPresent([String].self, forKey: .possibleRegexes)
        // TODO: Can we save completion blocks?
        self.validations = []
        self.validationsReq =  try container.decode(ValidationsRequired.self, forKey: .validationsReq)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("\(type)", forKey: .type)
        try container.encodeIfPresent(excludingCharachterSet, forKey: .excludingCharachterSet)
        try container.encodeIfPresent(requiredCharachterSet, forKey: .requiredCharachterSet)
        try container.encodeIfPresent(possibleRegexes, forKey: .possibleRegexes)
        try container.encode(validationsReq, forKey: .validationsReq)
        // TODO: Can we save completion blocks?
        // if let validations = validations {
        //     dlog?.note("Cannot encode RabacValidtions when Vapor is not imported")
        // }
    }
    
    // MARK: Public
    
    /// Validates a single parameter in a route.
    /// For instance, the request path:
    /// my/path/cfda5328-0c93-453e-9717-ca44331129d0/test
    /// vs. the Rabac route / matcher (NOTE THE COLON!):
    /// my/path/:UUID/test
    /// When iterating the components, when reahing the UID parameter (the 3rd path component)
    /// Should run a validation of the path component "cfda5328-0c93-453e-9717-ca44331129d0" as a string that can be used for a :UUID parameter
    /// - Parameters:
    ///   - value: single parameter value to validate
    ///   - fullPath: the full path containing the current parameter. (in case we need the "context" of this param for the validation)
    /// - Returns: success if parameter is valid, error if parameter is not valid (cannot be user as the param type we expect)
    func validate(value:String, fullPath:String)->RabacRouteMatchResult {
        
        // excludingCharachterSet
        // Check if contains any char in the excludingCharachterSet
        if let excludingCharachterSet = excludingCharachterSet {
            if value.replacingOccurrences(of: excludingCharachterSet, with: "").count < value.count {
                let msg = "validate(value:fullPath:) failed: value: \(value)) failed because it contains a charachter that is in the excludingCharachterSet: \(excludingCharachterSet.description)"
                dlog?.verbose(log: .fail, msg)
                return .failure(.init(code: .misc_failed_validation, reason: msg))
            }
        }
        
        // requiredCharachterSet
        // If requiredCharachterSet exists, make sure all chars are from requiredCharachterSet
        if let requiredCharachterSet = requiredCharachterSet {
            if value.replacingOccurrences(of: requiredCharachterSet, with: "").count > 0 {
                let msg = ".validate(value:fullPath:) failed:value: \(value)) failed  because it contains a charachter that is NOT in the requiredCharachterSet: \(requiredCharachterSet.description)"
                dlog?.verbose(log: .fail, msg)
                return .failure(.init(code: .misc_failed_validation, reason: msg))
            }
        }
        
        // possibleRegexes
        do {
            for regexStr in possibleRegexes ?? [] {
                let regex = try Regex<Substring>(regexStr)
                //  regex.firstMatch(in: value)
                if let _ = value.firstMatch(of: regex) {
                    return .success("Regex: '\(regexStr)' matched param: '\(value)'")
                    // break
                }
            }
        } catch let error {
            let msg = ".validate(value:\(value)) failed because regex strings threw: \(error.description)"
            dlog?.note(msg)
            return .failure(.init(code: .misc_failed_validation, reason: msg))
        }
        
        // Validations using completion blocks:
        if let valids = self.validations {
            var validCount = 0
            var minRequiredCount = 0
            
            switch self.validationsReq {
            case .allValid:                    minRequiredCount = valids.count
            case .atLeastSomeValid( let cnt):  minRequiredCount = cnt
            case .atLeastOneValid:             minRequiredCount = 1
            }
            
            for validation in valids {
                let isValid = validation(value, fullPath)
                
                // Check count vs required validation count:
                if isValid {
                    validCount += 1
                    if validCount > minRequiredCount {
                        return .success("Validation count \(validationsReq) echived!")
                    }
                } else if /* !isValid && */ self.validationsReq == .allValid  {
                    // will cut the loop now!
                    return .failure(.init(code: .misc_failed_validation, reason: "At least one validation block failed in validations (blocks) for: '\(value)'"))
                    // break
                }
            }
        }
        
        return .failure(.init(code: .misc_failed_validation, reason: "failed validation for an unknown reason. value: '\(value)' in fullPath: '\(fullPath)' vs. matcher keynamed: '\(self.keyName)'"))
    }

    /// Will parse the parameter using the value string and the (assumed) registered param type
    /// - Parameters:
    ///   - value: string value of the actual parameter in the request path
    ///   - fullPath: the full request path. (in case we need the "context" of this param for the parse action)
    /// - Returns: either a parameter of the expectedd type T or nil
    func parse<T:RabacRouteParamable>(value:String, fullPath:String)->T? {
        // self.type = StringAnyDictionary.getType(typeName: typeName) as! RabacRouteParamable
        guard let instance = T(value) else {
            dlog?.note("parse<T:\(T.self)> failed creating an instance!")
            return nil
        }
        
        var result : T? = nil
        
        if Swift.type(of: instance) == Swift.type(of: self.type) {
            result = nil
            dlog?.todo("parse<T:RabacRouteParamable>(value:String....")
        }
        
        return result
    }
}

