//
//  RRabacPermissionGiver.swift
//  
//
//  Created by Ido on 06/07/2023.
//

import Foundation
import Vapor

public protocol RRabacPermissionGiver {
    
    func isAllowed(for selfUser:RRabacUser?,
                   to action:any Codable,
                   on subject:RRabacPermissionResource?,
                   during req:Request?,
                   params:[String:Any]?)->RRabacPermission
}
