//
//  RabacError.swift
//  
//
//  Created by Ido on 01/03/2023.
//

import Foundation

typealias RabacErrCode = Int

// NOTE: Some cases are aliases for the same values!!
extension RabacErrCode {
    // Cases
    static let unknown : RabacErrCode = 0
    
    // Aliases
    static let missingInfo : RabacErrCode = 400 // AppErrorCode.http_stt_badRequest.code // malformed
    static let badRequest : RabacErrCode = 400 // AppErrorCode.http_stt_badRequest.code // malformed
    static let malformedRequest : RabacErrCode = 400 // AppErrorCode.http_stt_badRequest.code // malformed
    
    static let forbidden : RabacErrCode = 403 // AppErrorCode.http_stt_forbidden.code
    static let notRelevant : RabacErrCode = 412 // AppErrorCode.http_stt_preconditionFailed

    static let misc_failed_loading : RabacErrCode = 9001
    static let misc_failed_saving : RabacErrCode = 9002
    static let misc_failed_crypto : RabacErrCode = 9022
    static let misc_failed_parsing : RabacErrCode = 9030
    static let misc_failed_encoding : RabacErrCode = 9031
    static let misc_failed_decoding : RabacErrCode = 9032  // AppErrorCode.misc_failed_decoding
    static let misc_failed_validation : RabacErrCode = 9033
    static let misc_already_exists : RabacErrCode = 9034
    static let misc_security : RabacErrCode = 9050
}

protocol RabacForbidden {
    var code : RabacErrCode { get }
    var reason : String { get }
}

struct RabacError : RabacForbidden, Error, Codable, Hashable, CustomDebugStringConvertible {

    public static let domain = "com.idorabin.Rabac.RabacError"
    public let code : RabacErrCode
    public let reason : String
    
    var debugDescription: String {
        return "<RabacError: \(code) reason: \(reason)>"
    }
}
