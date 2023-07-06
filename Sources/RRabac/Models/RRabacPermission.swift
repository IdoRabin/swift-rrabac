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

final public class RRabacPermission: RRabacModel {
    public static let schema = "rrabac_permissions"

    // MARK: CodingKeys
    enum CodingKeys : String, CodingKey, CaseIterable {
        case id = "id"
        case name = "name"
        case desc = "desc"
        
        var fieldKey : FieldKey {
            return .string(self.rawValue)
        }
    }
    
    // MARK: Properties
    @ID(key: .id)
    public var id: UUID?
    public var mnUID : MNUID? {
        guard let uid = self.id else {
            return nil
        }
        return RRabacPermissionUID(uid: uid)
    }
    
    @Field(key: CodingKeys.name.fieldKey)
    public var name: String // name of the permission
    
    @Field(key: CodingKeys.desc.fieldKey)
    public var desc: String // name of the permission

    // The roles owning the permission?
    @Siblings(through: RRabacRolePermission.self, from: \.$permission, to: \.$role)
    public var roles: [RRabacRole]
    
    //  MARK: Lifecycle
    // Vapor migration requires empty init
    required public init() {
        self.id = UUID()
        self.name = "<?>"
    }

    fileprivate init(id:UUID, name: String, desc: String = "") {
        self.id = id
        self.name = name
        self.desc = desc
    }

    // MARK: Migration
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        // TODO: find out how to define limited-length string - i.e something like varchar(size) fields
        // https://stemmetje.com/2020/05/defining-a-varchar-column-in-vapor-4/
        // We can use : .custom("VARCHAR(100)")
        // In SQLite it will be automatically translated to a TEXT column. (no error on migration)
        database.schema(RRabacHitsoryItem.schema)
            .id() // primary key
            .field(CodingKeys.name.fieldKey, .string, .required)
            .field(CodingKeys.desc.fieldKey, .string)
            .ignoreExisting().create()
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Self.schema).delete()
    }
}