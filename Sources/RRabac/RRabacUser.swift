//
//  RRABACUser.swift
//  
//
//  Created by Ido on 31/05/2023.
//

import Foundation
import Vapor
import Fluent
import MNUtils
import DSLogger

public protocol RRabacUserable {
    var id: UUID? { get }
    var username: String? { get }
    var email: String? { get }
}

final public class RRabacUser: Model, Content, MNUIDable {
    public static let schema = "users"
    
    @ID(key: .id)
    public var id: UUID?
    public var mnUID : MNUID? {
        guard let uid = self.id else {
            return nil
        }
        return RRabacUserUID(uid: uid)
    }
    
    @Field(key: "name")
    public var name: String
    
    @Field(key: "email")
    public var email: String
    
    @Siblings(through: RRabacUserRole.self, from: \.$user, to: \.$role)
    public var roles: [RRabacRole]
    
    @Siblings(through: RRabacUserGroup.self, from: \.$user, to: \.$group)
    public var groups: [RRabacGroup]

    public init() {}

    public init(id: UUID? = nil, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}
