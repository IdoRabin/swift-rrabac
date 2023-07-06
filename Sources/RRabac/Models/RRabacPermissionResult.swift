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

// public typealias RRabacPermissionResult = MNPermission<RRabacPermissionID, MNError>
final public class RRabacPermissionResult: RRabacModel {
    public static let schema = "rrabac_permission_results"

    // MARK: CodingKeys
    enum CodingKeys : String, CodingKey, CaseIterable {
        case id = "id"
        case action = "action"
        case error = "error"
        case notes = "notes"
        
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
        
    }

    fileprivate init(id:UUID, action: RRabacCRUDAction, error: MNError? = nil, notes:String? = nil) {
        self.id = id
        self.action = action
        self.error = error
        self.notes = notes
    }

    // MARK: Migration
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        // database.createOrGetEnumType()
        database.schema(RRabacHitsoryItem.schema)
            .id() // primary key
            // .field(CodingKeys.action.fieldKey, .e, .required)
            .field(CodingKeys.error.fieldKey, .json)
            .field(CodingKeys.notes.fieldKey, .string)
            .ignoreExisting().create()
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Self.schema).delete()
    }
}
