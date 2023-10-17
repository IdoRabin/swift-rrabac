//
//  File.swift
//  
//
//  Created by Ido on 01/06/2023.
//

import Foundation
import Vapor
import Fluent
import MNUtils
//import DSLogger

final class RRabacUserGroup: RRabacModel {
    public static var mnuidTypeStr: String = RRabacMNUIDType.userGroup
    static let schema = "user_groups"

    // MARK: CodingKeys
    enum CodingKeys : String, CodingKey, CaseIterable {
        case id = "id"
        case user = "user_id"
        case group = "group_id"
        
        var fieldKey : FieldKey {
            return .string(self.rawValue)
        }
    }
    
    // MARK: Properties
    @ID(key: .id)
    var id: UUID?
    var mnUID: MNUID? {
        return RRabacUserGroupUID(uid: id!, typeStr: RRabacMNUIDType.userGroup)
    }
    
    @Parent(key: CodingKeys.user.fieldKey)
    var user: RRabacUser

    @Parent(key: CodingKeys.group.fieldKey)
    var group: RRabacGroup

    //  MARK: Lifecycle
    // Vapor migration requires empty init
    init() {}

    init(userID: UUID, groupID: UUID) {
        self.$user.id = userID
        self.$group.id = groupID
    }
    
    // MARK: Migration
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema)
            .id() // primary key
            .field(CodingKeys.user.fieldKey,  .uuid,  .required)
            .field(CodingKeys.group.fieldKey, .uuid,  .required)
            .ignoreExisting().create()
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema).delete()
    }
}
