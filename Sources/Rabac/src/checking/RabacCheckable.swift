//
//  RabacCheck.swift
//  Rabac
//
//  Created by Ido on 01/03/2023.
//

import Foundation

protocol RabacCheckable {
    
    // This check is stati - i.e never changes and does not require different instances / variables to work.
    var isStatic : Bool  { get }
    func check(context:RabacContext) async -> RabacPermission
}

extension Sequence where Element : RabacCheckable {
    // MARK: RabacCheckable
    
    func check(context:RabacContext) async -> RabacPermission {
        var res : RabacPermission = .forbidden(code: .forbidden, reason: "No Permissions"  + DLog.detailOrEmpty("Sequence where Element : RabacCheckable has 0 items!"))
        
        for item in self {
            res = await item.check(context: context)
            if res.isForbidden {
                break;
            }
        }
        
        return res
    }
}


extension Dictionary where Value : RabacCheckable {
    
    func check(context:RabacContext) async -> RabacPermission {
        var res : RabacPermission = .forbidden(code: .forbidden, reason: "No Permissions"  + DLog.detailOrEmpty("Sequence where Element : RabacCheckable has 0 items!"))
        
        for (_ , item) in self {
            res = await item.check(context: context)
            if res.isForbidden {
                break;
            }
        }
        
        return res
    }
}

