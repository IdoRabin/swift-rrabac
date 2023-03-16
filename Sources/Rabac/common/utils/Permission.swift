//
//  Permission.swift
//  
//
//  Created by Ido on 06/12/2022.
//

import Foundation
fileprivate let dlog : DSLogger? = DLog.forClass("Permission")


/// Permission is a generic enum built very similarly to the standart "Result" enum. This enum may have only two values:
///   .allowed(Allowed)     - containing an associated value of the generic type Allowed
///   .forbidden(Forbidden) - containing an associated value of the generic type Forbidden
@frozen public enum Permission<Allowed : Hashable, Forbidden: Hashable> : Hashable, Equatable where Forbidden : Error {
    
    /// A success, storing a `Success` value.
    case allowed(Allowed)
    
    /// A failure, storing a `Failure` value.
    case forbidden(Forbidden)
    
    var isAllowed : Bool {
        switch self {
        case .allowed:    return true
        case .forbidden:  return false
        }
    }
    
    var isForbidden : Bool {
        return !self.isAllowed
    }
    
    var allowedValue : Allowed? {
        switch self {
        case .allowed(let success): return success
        case .forbidden:  return nil
        }
    }
    
    var forbiddenValue : Forbidden? {
        switch self {
        case .allowed: return nil
        case .forbidden(let forbidden): return forbidden
        }
    }
    
    // MARK: Hqshable
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .allowed(let allow):    hasher.combine(allow)
        case .forbidden(let forbid): hasher.combine(forbid)
        }
    }
    
    // MARK: Equatable
    static func ==(lhs:RabacPermission, rhs:RabacPermission)->Bool {
        guard lhs.isAllowed == rhs.isAllowed else {
            return false
        }
        if lhs.isForbidden && lhs.forbiddenValue == rhs.forbiddenValue {
            return true
        } else if lhs.isAllowed && lhs.allowedValue == rhs.allowedValue {
            return true
        }
        
        return false
    }
}

