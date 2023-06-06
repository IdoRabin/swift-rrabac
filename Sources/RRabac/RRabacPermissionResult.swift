//
//  RRabacPermissionResult.swift
//  RRabac
//
//  Created by Ido on 05/06/2023.
//

import Foundation
import Vapor
import Fluent
import MNUtils
import DSLogger

public typealias RRabacPermissionID = String

public typealias RRabacPermissionResult = MNPermission<RRabacPermissionID, MNError>

extension RRabacPermissionResult : Codable {

    enum CodingKeys : String, CodingKey {
        
        // Basic
        case allowed             = "allowed"
        case forbidden           = "forbidden"
    }

    // MARK: Codable
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let allowed = try container.decodeIfPresent(Allowed.self, forKey: .allowed) {
            self = .allowed(allowed)
        } else if let forbidden = try container.decodeIfPresent(Forbidden.self, forKey: .forbidden) {
            self = .forbidden(forbidden)
        }
        
        throw MNError(.misc_failed_decoding, reason: "\(Self.self) failed decoding (no allowed AND no forbidden).")
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(allowedValue, forKey: .allowed)
        try container.encodeIfPresent(forbiddenValue, forKey: .forbidden)
    }
}
