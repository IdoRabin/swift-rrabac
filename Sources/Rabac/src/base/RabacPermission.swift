//
//  RabacPermission.swift
//  Rabac
//
//  Created by Ido on 02/03/2023.
//

import Foundation

// MARK: All names:
typealias RabacPermission = Permission<RabacAuthId, RabacError>
extension RabacPermission :  CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .forbidden(let err):
            return "<\("RabacPermission forbidden: \(err.code) reason: \(err.reason)")>"
        case .allowed(let id):
            return "<\("RabacPermission allowed: \(id.value)")>"
        }
    }
    
    static func forbidden(code:RabacErrCode, reason:String)->RabacPermission {
        return .forbidden(RabacError(code: code, reason: reason))
    }
    
    static func unknownForbidden(reason:String)->RabacPermission {
        return RabacPermission.forbidden(code: .forbidden, reason: reason)
    }
}
