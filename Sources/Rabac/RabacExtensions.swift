//
//  RabacExtensions.swift
//  
//
//  Created by Ido on 13/03/2023.
//

import Foundation

fileprivate let dlog : DSLogger? = DLog.forClass("RabacExtensions")?.setting(verbose: true)

extension UUID : RabacRouteParamable {
    
    
    /// Regex for parsing / valifdatinmg a 8-4-4-4-12 UUID string
    public static var REGEX : String {
        return "^[0-9a-fA-F]{8}\\b-[0-9a-fA-F]{4}\\b-[0-9a-fA-F]{4}\\b-[0-9a-fA-F]{4}\\b-[0-9a-fA-F]{12}$"
    }
    
    public init?(_ description: String) {
        guard description.count >= UID_EMPTY_STRING.count else {
            dlog?.note("UUID.init(_ description:String) Expected UID of format 8-4-4-4-12 (chars)")
            return nil
        }
        
        if let uid = UUID(uuidString: description) {
            self = uid
            return
        }
        
        return nil
    }
}

extension BUID : RabacRouteParamable {
    
}
