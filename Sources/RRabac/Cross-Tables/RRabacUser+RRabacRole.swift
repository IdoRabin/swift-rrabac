//
//  RRabacUser+RRabacRole.swift
//  
//
//  Created by Ido on 01/06/2023.
//

import Foundation
import Vapor
import Fluent
//import MNUtils
//import DSLogger

final class RRabacUserRole: Model {
    static let schema = "user_roles"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: RRabacUser

    @Parent(key: "role_id")
    var role: RRabacRole
    
    init() {}

    init(userID: UUID, roleID: UUID) {
        self.$user.id = userID
        self.$role.id = roleID
    }
}
