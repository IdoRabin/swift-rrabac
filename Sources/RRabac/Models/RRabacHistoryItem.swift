//
//  File.swift
//  
//
//  Created by Ido on 05/06/2023.
//

import Foundation
import Vapor
import Fluent
import MNUtils
import DSLogger

// , Authenticatable,

final public class RRabacHitsoryItem : RRabacModel {
    public static var schema: String = "rrabac_history"
    
    // MARK: CodingKeys
    enum CodingKeys : String, CodingKey, CaseIterable {
        case id = "id"
        case permissionResult = "permission_result"
        case createdDate = "created_date"
        case permissionGiverId = "permission_giver_id"
        case permissionSubject = "permission_subject"
        
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
    
    // 
    @Field(key: CodingKeys.permissionResult.fieldKey)
    var permissionResult : RRabacPermissionResult?
    
    // Trigger should only support .create!
    // Time of the CRUD
    @Timestamp(key: CodingKeys.createdDate.fieldKey, on: .create, format: .default)
    var createdDate : Date?
    
    // The id of the person / user that CRUDed the subject
    @Field(key: CodingKeys.permissionGiverId.fieldKey)
    var permissionGiverId : MNUID?
    
    // The item that was CRUDed:
    @Field(key: CodingKeys.permissionSubject.fieldKey)
    var permissionSubject : RRabacPermissionSubject?
    
    //  MARK: Lifecycle
    // Vapor migration requires empty init
    public required init() {
        
    }
    
    // MARK: Migration
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(RRabacHitsoryItem.schema)
            .id() // primary key
            .field(CodingKeys.permissionResult.fieldKey,  .json,     .required)
            .field(CodingKeys.createdDate.fieldKey,       .datetime, .required)
            .field(CodingKeys.permissionGiverId.fieldKey, .uuid,     .required)
            .field(CodingKeys.permissionSubject.fieldKey, .json,     .required)
            .unique(on: .id)
            .ignoreExisting().create()
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Self.schema).delete()
    }
}


/*
@Field(key: "result")
var result : RRabacPermissionResult?

@Timestamp(key: "date", on: TimestampTrigger.create, format: .default)
var date : Date?

@Field(key: "permission_owner")
var permission_giver_id : UUID?

*/
