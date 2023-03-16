//
//  ErrorEx.swift
//  
//
//  Created by Ido on 21/06/2022.
//

import Foundation

extension Error {
    
    var description : String {
        var result = "<unknown error \(type(of: self)) \(self.localizedDescription)>"
        
        // DO NOT USE SWITCH CASE
        // NOTE: Order of conditions matters here!
        let typeStr = "\(type(of: self))"
        if typeStr.contains(anyOf: ["AppError"]) { // AppError trick
            result = self.description
        } else if typeStr.contains(anyOf: ["RabacError"]) { // AppError trick
            let err = self as! RabacError
            result = "<RabacError: \(err.code)|\(err.reason)>"
        } else if type(of: self) == NSError.self {
            let nserror = self as NSError
            result = "\(nserror.domain):\(nserror.code)"
            let debugDes = nserror.debugDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            if !result.contains(debugDes) {
                result += " \(debugDes)."
            }
            if let str = nserror.localizedFailureReason {
                result += " \(str)."
            }
            if let str = nserror.localizedRecoveryOptions {
                result += " \(str)."
            }
            if let str = nserror.localizedRecoverySuggestion {
                result += " \(str)."
            }
            if !nserror.userInfo.isEmpty {
                result += "\n user info: \(nserror.userInfo)"
            }
            if #available(macOS 11.3, *) {
                for err in nserror.underlyingErrors {
                    result += "\n  underlying error: \(err.description)"
                }
            }
        } else {
            if RabacDebug.IS_DEBUG {
                result = String(describing: self)
            } else {
                result = self.localizedDescription
            }
            
        }
        
        return result
    }
    
}

extension NSError {
    var reason : String {
        return self.localizedDescription // ?? self.localizedFailureReason ?? self.description
    }
}
