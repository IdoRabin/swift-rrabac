//
//  RRabacPermission.swift
//  
//
//  Created by Ido on 01/06/2023.
//

import Foundation
import Vapor
import Fluent
import MNUtils
import DSLogger

final public class RRabacPermission: Model, Content, MNUIDable {
    public static let schema = "permissions"

    @ID(key: .id)
    public var id: UUID?
    public var mnUID : MNUID? {
        guard let uid = self.id else {
            return nil
        }
        return RRabacPermissionUID(uid: uid)
    }
    
    @Field(key: "name")
    var name: String // name of the permission

    @Siblings(through: RRabacRolePermission.self, from: \.$permission, to: \.$role)
    public var roles: [RRabacRole]
    
    public init() {}

    public init(id:UUID, name: String) {
        self.id = id
        self.name = name
    }
}
