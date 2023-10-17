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

public protocol Userable : AnyObject {
    var id: UUID? { get }
    var username: String? { get }
    var useremail: String? { get }
    var domain: String? { get }
}

public enum UserableCodingKeys : String, CodingKey, CaseIterable {
    case id = "id"
    case username = "username"
    case useremail = "useremail"
    case domain = "domain"
    
    var fieldKey : FieldKey {
        return .string(self.rawValue)
    }
}

final public class RRabacUser: RRabacModel, Userable {
    public static var mnuidTypeStr: String = RRabacMNUIDType.user
    public static let schema = "rrabac_users"
    
    // MARK: CodingKeys
    typealias CodingKeys = UserableCodingKeys
    
    // MARK: Properties
    @ID(key: .id)
    public var id: UUID?
    public var mnUID : MNUID? {
        guard let uid = self.id else {
            return nil
        }
        return RRabacUserUID(uid: uid)
    }
    
    @OptionalField(key: CodingKeys.username.fieldKey)
    public var username: String?
    
    @OptionalField(key: CodingKeys.useremail.fieldKey)
    public var useremail: String?
    
    @OptionalField(key: CodingKeys.domain.fieldKey)
    public var domain: String?
    
//    @Siblings(through: RRabacUserRole.self, from: \.$user, to: \.$role)
//    public var roles: [RRabacRole]
//
//    @Siblings(through: RRabacUserGroup.self, from: \.$user, to: \.$group)
//    public var groups: [RRabacGroup]

    //  MARK: Lifecycle
    // Vapor migration requires empty init
    public init() {}

    public init(id: UUID? = nil, username: String?, useremail: String?, domain:String) throws {

        guard (username?.count ?? 0) > 0 &&
              (useremail?.count ?? 0) > 0 else {
            throw MNError(code:.db_failed_init, reason: "RRabacUser failed init because both username and useremail are nil or empty")
        }
        
        self.id = id
        self.username = username
        self.useremail = useremail
        self.domain = domain
        
    }
    
    // MARK: Migration
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema)
            .id() // primary key
            .field(CodingKeys.username.fieldKey, .string)
            .field(CodingKeys.useremail.fieldKey, .string)
            .field(CodingKeys.domain.fieldKey, .string)
            .unique(on: CodingKeys.username.fieldKey, CodingKeys.useremail.fieldKey, CodingKeys.domain.fieldKey)
            .ignoreExisting().create()
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema).delete()
    }
}
