//
//  RRabacCRUDAction.swift
//  
//
// Created by Ido Rabin for Bricks on 17/1/2024.

import Foundation

public enum RRabacCRUDAction : String, Codable, CaseIterable {
    case create = "rrbc_create"
    case read   = "rrbc_read"
    case update = "rrbc_update"
    case delete = "rrbc_delete"
    
    static var name : String {
        return "\(Self.self)"
    }
}
