//
//  RabacType.swift
//  
//
//  Created by Ido on 01/03/2023.
//

import Foundation

enum RabacType : String, Codable, CaseIterable, LosslessStringConvertible  {
    
    case person         = "rabac_person"
    case rule           = "rabac_rule"
    case role           = "rabac_role"
    case resource       = "rabac_resource"
    case attribute      = "rabac_attribute"
    case action         = "rabac_action"
    
    // MARK: LosslessStringConvertible
    var description: String {
        return self.rawValue
    }
    
    init?(_ description: String) {
        switch description {
        case RabacType.person.description  :    self = .person
        case RabacType.rule.description :       self = .rule
        case RabacType.role.description :       self = .role
        case RabacType.resource.description :   self = .resource
        case RabacType.attribute.description :  self = .attribute
        case RabacType.action.description :     self = .action
        default:
            return nil
        }
    }
    
    // Listed all types in
    static let ALL_ELEMENT_TYPES : [String:RabacElement.Type] = [
        "RabacRole"     : RabacRole.self,
        "RabacAction"   : RabacAction.self,
        "RabacAttribute": RabacAttribute.self,
        "RabacResource" : RabacResource.self,
        "RabacElement"  : RabacElement.self,
        "RabacCheck"    : RabacCheck.self,
        "RabacRule"     : RabacRule.self,
        
        // "RabacPerson" is only a protocol, hence, not a concrete type...
    ]
    
    func elementType()->RabacElement.Type? {
        return Self.elementType(by: self)
    }
    
    static func elementType(by atype:RabacType)->RabacElement.Type? {
        switch atype {
        // "RabacPerson" is only a protocol, hence, not a concrete type...
        // case .person  :     return type(of: RabacPerson.self) as? RabacElement.Type?
            
        case .rule :        return RabacRule.self
        case .role :        return RabacRole.self
        case .resource :    return RabacResource.self
        case .attribute :   return RabacResource.self
        case .action :      return RabacAction.self
        default:
            return nil
        }
    }
}
