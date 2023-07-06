//
//  RRabacRole.swift
//  
//
//  Created by Ido on 01/06/2023.
//

import Foundation
import Vapor
import Fluent
import MNUtils
import DSLogger

final public class RRabacRole: RRabacModel {
    public  static let schema = "rrabac_roles"

    @ID(key: .id)
    public var id: UUID?
    public var mnUID : MNUID? {
        guard let uid = self.id else {
            return nil
        }
        return RRabacRoleUID(uid: uid)
    }
    
    @Field(key: "name")
    public var name: String // name of the role

    @Siblings(through: RRabacUserRole.self, from: \.$role, to: \.$user)
    public var users: [RRabacUser]

    @Siblings(through: RRabacRolePermission.self, from: \.$role, to: \.$permission)
    public var permissions: [RRabacPermission]
    
    @Siblings(through: RRabacRoleGroup.self, from: \.$role, to: \.$group)
    public var groups: [RRabacGroup]

    public init() {}

    public init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
