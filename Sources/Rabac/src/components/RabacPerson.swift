//
//  File.swift
//  
//
//  Created by Ido on 01/03/2023.
//

import Foundation

typealias AnyRababcPerson = any RabacPerson

fileprivate let dlog : DSLogger? = DLog.forClass("RabacPerson")

protocol RabacPerson : LosslessStringIdentifiable {
    
    /// RabacId is derived / equal to ID
    var rabacId : RabacID { get }
    var uidString : String { get }
    
    var roles : [RabacRole] { get }
    var attibutes : [RabacAttribute] { get }
    
    func isOwns(_ resourceValue:Any, info:[String:Any]) async ->Bool
    func allowsAccessTo(_ resourceValue:Any, info:[String:Any]) async ->Bool
}

extension RabacPerson /* default inmplementatins */ {
    
    var rabacId : RabacID {
        if let lid = ID.self as? any LosslessStringConvertible {
            return RabacID(type: .person, title: lid.description)
        } else {
            dlog?.info("RabacPerson requires that the type for \(Self.self).ID \(ID.self) conforms to LosslessStringConvertible! (RabacPerson should conform to LosslessStringIdentifiable)")
            return RabacID(type: .person, title: String(describing: self.id))
        }
    }
}
