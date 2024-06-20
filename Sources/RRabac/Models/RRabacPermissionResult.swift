//
//  RRabacPermission.swift
//
//
// Created by Ido Rabin for Bricks on 17/1/2024.

import Foundation
import Vapor
import Fluent
import MNUtils
import MNVaporUtils

// public typealias RRabacPermissionResult = MNPermission<RRabacPermissionID, MNError>
final public class RRabacPermissionResult: RRabacModel {
    public static var mnuidTypeStr: String = RRabacMNUIDType.historyItem
    public static let schema = "rrabac_permission_results"

    // MARK: CodingKeys
    enum CodingKeys : String, CodingKey, CaseIterable {
        case id = "id"
        case error = "error"
        case notes = "notes"
        case requesterId = "requester_id"
        case granterId = "granter_id"
        case requestedResourceId = "requested_resource_id"
        case action = "action"
        
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
        return RRabacHistoryItemUID(uid: uid)
    }
    
    @OptionalField(key: CodingKeys.requesterId.fieldKey)
    public var requesterId: MNUID?
    
    @Field(key: CodingKeys.granterId.fieldKey)
    public var granterId: MNUID
    
    @Field(key: CodingKeys.requestedResourceId.fieldKey)
    public var requestedResourceId: MNUID
    
    @Enum(key: CodingKeys.action.fieldKey)
    public var action: RRabacCRUDAction
    
    @OptionalField(key: CodingKeys.error.fieldKey)
    public var error: MNError?
    
    @OptionalField(key: CodingKeys.notes.fieldKey)
    public var notes: String? // name of the permission
    
    //  MARK: Lifecycle
    // Vapor migration requires empty init
    required public init() {
        self.id = UUID()
        self.action = .read
        self.error = nil
        self.notes = nil
        self.requesterId = nil
        
        self.granterId = MNUID.init(uid: UUID.empty, typeStr: RRabacMNUIDType.user)
        self.requestedResourceId = MNUID(uid: UUID.empty, typeStr: RRabacMNUIDType.user)
    }

    fileprivate init(id:UUID, action: RRabacCRUDAction, error: MNError? = nil, notes:String? = nil) {
        self.id = id
        self.action = action
        self.error = error
        self.notes = notes
    }

    // MARK: Migration
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.createOrGetCaseIterableEnumType(anEnumType: RRabacCRUDAction.self).flatMap { crudAction in
            
            // Model schema:
            return database.schema(Self.schema)
                .id() // primary key
                .field(CodingKeys.action.fieldKey, crudAction ,.required)
                .field(CodingKeys.error.fieldKey, .json)
                .field(CodingKeys.notes.fieldKey, .string)
                .field(CodingKeys.requesterId.fieldKey, .string)
                .field(CodingKeys.granterId.fieldKey, .string)
                .field(CodingKeys.requestedResourceId.fieldKey, .string)
                .ignoreExisting().create()
        }
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return  database.schema(Self.schema).delete().flatMap {
            return database.enum(RRabacCRUDAction.name).delete()
        }
    }
}
