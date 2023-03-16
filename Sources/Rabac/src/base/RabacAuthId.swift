//
//  RabacAuthId.swift
//  
//
//  Created by Ido on 01/03/2023.
//

import Foundation

fileprivate let dlog : DSLogger? = DLog.forClass("RabacAuthId")?.setting(verbose: false)

struct RabacAuthId : Codable, Hashable, CustomDebugStringConvertible {
    
    // MARK: Weapped static variables
    @Persist(name:"rabac.authIdCount", default:0) static var authIdCount : UInt64
    
    // MARK: Static
    static let DELIM = "|"
    static var latest : RabacAuthId? = nil
    
    // MARK: Properties / members
    let value : String
    var debugDescription: String {
        return "<RabacAuthId: \(value)>"
    }
    
    // MARK: Lifecycle
    private init(value: String) {
        self.value = value
        dlog?.success("NEW RabacAuthId: [\(value)]")
        // TODO: Logging for permissions granting>?
    }
    
    // MARK: Public static
    static func next()->RabacAuthId {
        var count = self.authIdCount
        count += 1
        let val = "AID\(DELIM)\(Date.now.formatted(.iso8601))\(DELIM)\(count)"
        self.authIdCount = count
        return RabacAuthId(value: val)
    }
    
    static func forChecking(_ elements:RabacElement...)->RabacAuthId {
        if Self.latest == nil {
            Self.latest = Self.next()
        }
        //for element in elements {
        // TODO: Create auth ids for all elements!?
        //}
        return RabacAuthId(value: latest!.value + DELIM + elements.first!.rabacIdString)
    }
    
    static func forChecking(_ person: any RabacPerson)->RabacAuthId {
        return RabacAuthId(value: "RabacPerson" + DELIM + person.idString)
    }
    
    static func forChecking(_ check: RabacCheck)->RabacAuthId {
        if Self.latest == nil {
            Self.latest = Self.next()
        }
        return RabacAuthId(value: latest!.value + DELIM + "\(type(of: check))")
    }
}
