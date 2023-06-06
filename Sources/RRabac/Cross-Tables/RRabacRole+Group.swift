//
//  RRabacRole+Group.swift
//  RRabac
//
//  Created by Ido on 04/06/2023.
//

import Foundation
import Vapor
import Fluent
//import MNUtils
//import DSLogger


final class RRabacRoleGroup: Model {
    
    static let schema = "role_groups"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "role_id")
    var role: RRabacRole

    @Parent(key: "group_id")
    var group: RRabacGroup

    init() {}

    init(roleID: UUID, groupId: UUID) {
        self.$role.id = roleID
        self.$group.id = groupId
    }
}
