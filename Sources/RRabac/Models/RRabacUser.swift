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

public protocol Userable {
    var id: UUID? { get }
    var username: String? { get }
    var email: String? { get }
    var domain: String? { get }
}

final public class RRabacUser: Model, Content, MNUIDable, Userable {
    public static let schema = "users"
    
    @ID(key: .id)
    public var id: UUID?
    public var mnUID : MNUID? {
        guard let uid = self.id else {
            return nil
        }
        return RRabacUserUID(uid: uid)
    }
    
    @Field(key: "username")
    public var username: String?
    
    @Field(key: "email")
    public var email: String?
    
    @Field(key: "domain")
    public var domain: String?
    
    @Siblings(through: RRabacUserRole.self, from: \.$user, to: \.$role)
    public var roles: [RRabacRole]
    
    @Siblings(through: RRabacUserGroup.self, from: \.$user, to: \.$group)
    public var groups: [RRabacGroup]

    public init() {}

    public init(id: UUID? = nil, username: String, email: String) {
        self.id = id
        self.username = username
        self.email = email
    }
}
