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
import MNVaporUtils
import DSLogger

// public typealias RRabacPermissionResult = MNPermission<RRabacPermissionID, MNError>
final public class RRabacPermissionResult: RRabacModel {
    public static let schema = "rrabac_permission_results"

    // MARK: CodingKeys
    enum CodingKeys : String, CodingKey, CaseIterable {
        case id = "id"
        case error = "error"
        case notes = "notes"
        case requesterId = "requester_id"
        case requestedAction = "requested_action"
        case granterId = "granter_id"
        case requestedResources = "requested_resources"
        
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
    
    @OptionalField(key: CodingKeys.requesterId.fieldKey)
    public var requesterId: MNUID?
    
    @Field(key: CodingKeys.granterId.fieldKey)
    public var granterId: MNUID
    
    @Field(key: CodingKeys.requestedResources.fieldKey)
    public var requestedResources: RRabacPermissionResource
    
    @Enum(key: CodingKeys.requestedAction.fieldKey)
    public var requestedAction: RRabacCRUDAction
    
    @OptionalField(key: CodingKeys.error.fieldKey)
    public var error: MNError?
    
    @OptionalField(key: CodingKeys.notes.fieldKey)
    public var notes: String? // notes regarding the permission
    
    //  MARK: Lifecycle
    // Vapor migration requires empty init
    required public init() {
        self.id = UUIDv5.empty
        self.error = nil
        self.notes = nil
        self.requesterId = nil
        self.requestedAction = .read
        self.requesterId = UserUID(uid: UUIDv5.empty)// MNUID.init(uid: UUIDv5.empty, typeStr: MNUIDType.user)
        self.granterId = UserUID(uid: UUIDv5.empty)// MNUID.init(uid: UUIDv5.empty, typeStr: MNUIDType.user)
        self.requestedResources = RRabacPermissionResource.empty
    }

    fileprivate init(id:UUID, action: RRabacCRUDAction, error: MNError? = nil, notes:String? = nil) {
        self.id = id
        self.requestedAction = action
        self.error = error
        self.notes = notes
    }

    // MARK: Migration
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.createOrGetCaseIterableEnumType(anEnumType: RRabacCRUDAction.self).flatMap { crudAction in
            // return database.eventLoop.makeSucceededVoidFuture() //  Debugging
            // Model schema:
            return database.schema(Self.schema)
                .id()  // primary key
                .field(CodingKeys.requesterId.fieldKey, .string)
                .field(CodingKeys.requestedAction.fieldKey, crudAction ,.required)
                .field(CodingKeys.requestedResources.fieldKey, .json)
                .field(CodingKeys.granterId.fieldKey, .string)
                .field(CodingKeys.error.fieldKey, .json)
                .field(CodingKeys.notes.fieldKey, .array(of: .string))
                .ignoreExisting().create()
        }
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Self.schema).delete().flatMap {
            return database.enum(RRabacCRUDAction.name).delete()
        }
    }
}
