//
//  RabacAttribute.swift
//  
//
//  Created by Ido on 11/01/2023.
//

import Foundation

class RabacAttribute : RabacElement {
    enum Base : String {
        // General actions
        case loggedIn      = "logged_in"
        case active        = "active"
        case readonly      = "readonly"
        case disabled      = "disabled"
        case blacklisted   = "blacklisted"
    }
    
//    static let loggedIn = RabacAttribute.self[Base.loggedIn.rawValue]
//    static let active = RabacAttribute.self[Base.active.rawValue]
//    static let readonly = RabacAttribute.self[Base.readonly.rawValue]
//    static let disabled = RabacAttribute.self[Base.disabled.rawValue]
//    static let blacklisted = RabacAttribute.self[Base.blacklisted.rawValue]

}
