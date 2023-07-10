//
//  RRabacMiddlewarw+Prefill.swift
//  
//
//  Created by Ido on 10/07/2023.
//

import Foundation

public extension RRabacMiddleware /* */ {
    func isMasterAccountExists() async -> Bool {
        var result = false
        return result
    }
    
    func isMasterGroupExists() async -> Bool {
        var result = false
        return result
    }
    
    @discardableResult
    func prefillDataIfNeeded() async -> Bool {
        guard await self.isMasterGroupExists() == false {
            // Master group already exists
            return false
        }
        
        guard await self.isMasterAccountExists() == false {
            // Master account already exists
            return false
        }
        
        
    }
}
