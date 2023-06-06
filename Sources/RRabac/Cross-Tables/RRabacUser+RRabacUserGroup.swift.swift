//
//  File.swift
//  
//
//  Created by Ido on 01/06/2023.
//

import Foundation
import Vapor
import Fluent
//import MNUtils
//import DSLogger

final class RRabacUserGroup: Model {
    static let schema = "user_groups"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: RRabacUser

    @Parent(key: "group_id")
    var group: RRabacGroup

    init() {}

    init(userID: UUID, groupID: UUID) {
        self.$user.id = userID
        self.$group.id = groupID
    }
}
