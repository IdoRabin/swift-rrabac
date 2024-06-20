//
//  RRabacPermissionGiver.swift
//  
//
// Created by Ido Rabin for Bricks on 17/1/2024.

import Foundation
import Vapor

public protocol RRabacPermissionGiver {
    
    func isAllowed(for selfUser:RRabacUser?,
                   to action:any Codable,
                   on subject:RRabacPermissionSubject?,
                   during req:Request?,
                   params:[String:Any]?)->RRabacPermission
}
