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

final class RRabacHitsoryItem : Model, Content, MNUIDable {
    static var schema: String = "rrabac_history"
    
    @ID(key: .id)
    var id: UUID?
    
    var mnUID : MNUID? {
        guard let uid = self.id else {
            return nil
        }
        return RRabacPermissionUID(uid: uid)
    }
    
    @Field(key: "result")
    var result : RRabacPermissionResult?
    
    // Trigger should only support .create!
    @Timestamp(key: "created_date", on: .create, format: .default)
    var createdDate : Date?
    
    @Field(key: "permission_giver_id")
    var permissionGiverId : MNUID?
    
    @Field(key: "permission_subject")
    var permissionSubject : RRabacPermissionSubject?
    
    required init() {
        
    }
}

/*
@Field(key: "result")
var result : RRabacPermissionResult?

@Timestamp(key: "date", on: TimestampTrigger.create, format: .default)
var date : Date?

@Field(key: "permission_owner")
var permission_giver_id : UUID?


extension RRabacPermission  {
    static func forbidden(code:Int, reason:String)->RRabacPermission {
        return .forbidden(mnError: MNError(MNErrorCode(rawValue: code)!, reason: reason))
    }
    
    static func forbidden(code:MNErrorCode, reason:String)->RRabacPermission {
        return .forbidden(mnError: MNError(code, reason: reason))
    }

    static func forbidden(mnError:MNError)->RRabacPermission {
        let code = MNErrorCode(rawValue: mnError.code)
        let mnError : MNError = MNError(code ?? .misc_unknown, reasons: mnError.reasons ?? [])
        return RRabacPermission(
    }
}
*/
