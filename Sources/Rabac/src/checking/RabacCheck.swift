//
//  RabacCheck.swift
//  Rabac
//
//  Created by Ido on 02/03/2023.
//

import Foundation
#if VAPOR
import Vapor
#endif

fileprivate let dlog : DSLogger? = DLog.forClass("Rabac+Checks")

#if VAPOR
protocol RabacVaporCheckable {
    func check(vaporRequest:Vapor.Request, context: [RabacContextKey : Any]) async -> RabacPermission
}
#endif

extension RabacCheckable {
    
    // Default!
    var isStatic : Bool  {
        // This check is stati - i.e never changes and does not require different instances / variables to work.
        return true
    }
}

class RabacCheck : RabacElement, RabacCheckable {
    
    var params : [String] = []
    var paramsJoined : String {
        // Computed
        return params.joined(separator: ", ")
    }
    
    func check(context: RabacContext) async -> RabacPermission {
        // "Abstreact" implementation:
        let person = context.person?.idString ?? "<Unknown person UID>"
        if RabacDebug.IS_DEBUG {
            dlog?.warning("\(Self.self).\(self.rabacId.title) needs to implement check(context: RabacContext) person: \(person)")
            return .allowed(RabacAuthId.forChecking(self))
        } else {
            return .forbidden(code:.forbidden, reason: "No permission.")
        }
    }
    
    class override func className()->String {
        return "RabacCheck"
    }
    
    // MARK: StringAnyInitable
    /* override */ required init(stringAnyDict dict: StringAnyDictionary) throws {
        try super.init(stringAnyDict: dict)
    }
    
    // MARK: Lifecycle
    required init(_ newRabacName: String, isValidateNameUniqueness isValidate: Bool = true) throws {
        try super.init(title:newRabacName, isValidateNameUniqueness: isValidate)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
