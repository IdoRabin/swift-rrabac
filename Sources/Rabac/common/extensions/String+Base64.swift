//
//  String+Base64.swift
//  Base64 extensions with String
//
//  Created by Ido on 17/08/2022.
//

import Foundation


extension String  /* base64 */ {
    
    func fromBase64() throws -> String{
        guard let data = Data(base64Encoded: self) else {
            throw RabacError(code:.misc_failed_decoding, reason: "String.fromBase64 does not seem to be a base64 string. Is is escaped or percent encoded?")
        }
        guard let str = String(data: data, encoding: .utf8) else {
            
            // Fallback from utf16 for externally sourced string:
            if let str = String(data: data, encoding: .utf16) {
                return str
            }
            
            throw RabacError(code:.misc_failed_decoding, reason: "String.fromBase64 does not interpret as a utf8 string. Data is not decodable.")
        }
        
        return str
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self), data.count > 0 else {
            return nil
        }
        
        // Contains fallback for utf16 for externally sourced string:
        return String(data: data, encoding: .utf8) ?? String(data: data, encoding: .utf16)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

extension String /* protobuf */ {
    
    func toProtobuf() -> String {
        DLog.misc["String+Protobuf"]?.warning(".toProtobuf() IMPLEMENT PROTOBUF! ")
        return self
    }
    
    func fromProtobuf() throws -> String {
        DLog.misc["String+Protobuf"]?.warning(".fromProtobuf() IMPLEMENT PROTOBUF!")
        
        return self
    }
    
    func fromProtobuf() -> String? {
        DLog.misc["String+Protobuf"]?.warning(".fromProtobuf() IMPLEMENT PROTOBUF!")
        do {
            let str : String = try self.fromProtobuf()
            return str
        } catch let error {
            DLog.misc["String+Protobuf"]?.warning(".fromProtobuf() Threw error:\(String(describing: error))")
        }
        return nil
    }
}
