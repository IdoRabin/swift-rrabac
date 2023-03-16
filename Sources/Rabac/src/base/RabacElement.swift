//
//  RabacElement.swift
//  Rabac
//
//  Created by Ido on 01/03/2023.
//

import Foundation

fileprivate let dlog : DSLogger? = DLog.forClass("RabacElement")?.setting(verbose: false)

class RabacElement : Codable, Hashable, CustomStringConvertible {
    
    // MARK: Properties
    var rabacId : RabacID
    var rabacIdString : String {
        return rabacId.description
    }
    
    // MARK: Class
    class func className()->String {
        return "\(Self.self)"
    }
    
    enum CodingKeys : String, CodingKey {
        case rabacId = "rabac_id"
    }
    
    class var type : RabacType {
        switch Self.className() {
        case "RabacPerson":      return .person
        case "\(RabacRule.self)":        return .rule
        case "\(RabacRole.self)":        return .role
        case "\(RabacResource.self)":    return .resource
        case "\(RabacAttribute.self)":   return .attribute
        default:
            preconditionFailure("RabacElement must implement a subclass which returns type : RabacType")
        }
    }
    
    // MARK: Equatable
    static func ==(lhs:RabacElement, rhs:RabacElement)->Bool {
        return lhs.rabacId == rhs.rabacId
    }
    
    // MARK: Hahsable
    func hash(into hasher: inout Hasher) {
        hasher.combine(rabacId)
    }
    
    // MARK: Static
    
    static func isIdRegistered(_ id : RabacID)->Bool {
        return RabacMgr.shared.isIdRegistered(id)
    }
    
    static func getRabacType(byName typeName:String)->RabacElement.Type? {
        if let rtype = RabacType(typeName), let elemType = rtype.elementType() {
            return elemType
        } else {
            let result = RabacType.ALL_ELEMENT_TYPES[typeName] ?? (StringAnyDictionary.getType(typeName: typeName)?.type as? RabacElement.Type)
            return result
        }
    }
    
    private static func extractRabacId(fromDict dict:StringAnyDictionary)->RabacID? {
        var result : RabacID? = nil
        if let rid : RabacID = (dict["id"] ?? dict[CodingKeys.rabacId.rawValue]) as? RabacID {
            result = rid
        } else if let ridStr : String = (dict["id"] ?? dict[CodingKeys.rabacId.rawValue]) as? String {
            result = RabacID(ridStr) // LosslessStringConvertible
        }
        return result
    }
    
    // Default inits
    // MARK: Lifecycle
    init(rabacId:RabacID, isValidateNameUniqueness isValidate: Bool = true) throws {
        if isValidate && Self.isIdRegistered(rabacId) {
            dlog?.raisePreconditionFailure("init(id:isValidateNameUniqueness:) id [\(rabacId)] is NOT unique!")
        }
        self.rabacId = rabacId
    }
    
    init(title:String, isValidateNameUniqueness isValidate: Bool = true) throws {
        let rid = RabacID(type: Self.type, title: title)
        if isValidate && Self.isIdRegistered(rid) {
            dlog?.raisePreconditionFailure("init(title:isValidateNameUniqueness:) id [\(rid)] is NOT unique!")
        }
        self.rabacId = rid
    }
    
    // MARK: Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.rabacId = try container.decode(RabacID.self, forKey: .rabacId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.rabacId, forKey: .rabacId)
    }
    
    // MARK: CustomStringConvertible
    var description: String {
        return "<\(Self.self) \(String(memoryAddressOf: self)) \(self.rabacId.title.trimming(string: "/"))>"
    }
    
    // MARK: StringAnyInitable
    /*
    class func createInstance(stringAnyDict dict:StringAnyDictionary, typeName:String?)->RabacElement? {
        guard let rabacType = RabacType(typeName ?? "\(Self.self)") else {
            dlog?.warning("RabacElement:StringAnyInitable.createInstance(dict) failed finding type")
            return nil
        }
        
        guard let rabacId = Self.extractRabacId(fromDict: dict) else {
            dlog?.warning("RabacElement:StringAnyInitable.createInstance(dict) failed finding rabacId")
            return nil
        }
        
        var result : RabacElement? = nil
        
        if let element = Rabac.shared.elements[rabacId] {
            if Rabac.IS_DEBUG && rabacId.type != rabacType {
                dlog?.warning("RabacElement:StringAnyInitable.createInstance(dict) failed: existing type: \(rabacId.type) != rabacType \(rabacType)")
            }
            
            // Exiting instance
            return element
        } else {
            result = rabacType.newOrGetElement(rabacId, dict: dict).successValue
        }
        return result
    }
     */
    
    required init(stringAnyDict dict:StringAnyDictionary) throws {
        guard let newRabacId = Self.extractRabacId(fromDict: dict) else {
            var msg = "\(Self.self):StringAnyInitable.createInstance(stringAnyDict) failed finding rabacId"
            if RabacDebug.IS_DEBUG {
                msg += " in dict: \(dict)"
            }

            dlog?.warning(msg)
            throw RabacError(code: .missingInfo, reason: msg)
        }
        
        // We validate uniqeness
        if Self.isIdRegistered(newRabacId) {
            dlog?.warning("\(Self.self):StringAnyInitable.createInstance(stringAnyDict) id is already registered")
        } else {
            dlog?.success("\(Self.self).init(stringAnyDict:...) \(newRabacId))")
        }
        

        self.rabacId = newRabacId
    }
    
    
}


extension Sequence where Element : RabacElement {
    
    var ids : [RabacID] {
        return self.map { $0.rabacId }
    }
    
    var idStrings : [String] {
        return self.map { $0.rabacIdString }
    }
    
    var idTitles : [String] {
        return self.map { $0.rabacId.title }
    }
}
