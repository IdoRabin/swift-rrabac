//
//  RRabacPermissionSubject.swift
//  
//
//  Created by Ido on 06/07/2023.
//

import Foundation
import MNUtils
import MNVaporUtils

public enum RRabacPermissionResourceType : String, Codable, CaseIterable, Hashable, JSONSerializable  {
    case users
    case files
    case routes
    case webpages
    case models
    case commands
    case underermined
    
    // MARK: Equatable
    public static func ==(lhs:RRabacPermissionResourceType, rhs:RRabacPermissionResourceType)->Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    // MARK: Hahsable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawValue)
    }
}

public struct RRabacPermissionResource : JSONSerializable, Hashable {
    let type : RRabacPermissionResourceType
    let ids : [String]
    
    static var empty : RRabacPermissionResource {
        return RRabacPermissionResource(type: .underermined, ids: [])
    }
}
