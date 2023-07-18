//
//  RRabacMiddlewarw+Prefill.swift
//  
//
//  Created by Ido on 10/07/2023.
//

import Foundation
import FluentKit
import Fluent
import MNUtils
import MNVaporUtils

public struct UseLoginInfo {
    
}

public extension RRabacMiddleware /* Prefill */ {
    
    func isMasterAccountExists(named:String, db:Fluent.Database) async -> Bool {
        var result = false
        return result
    }
    
    func isMasterGroupExists(named:String, db:Database) async -> Bool {
        var result = false
        return result
    }
}
