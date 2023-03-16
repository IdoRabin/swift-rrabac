//
//  LosslessStringIdentifiable.swift
//  Rabac
//
//  Created by Ido on 01/03/2023.
//

import Foundation

protocol LosslessStringIdentifiable : Identifiable where ID : LosslessStringConvertible {
    var idString : String { get }
}

extension LosslessStringIdentifiable /* Default implementation */ {
    var idString : String {
        return self.id.description
    }
}
