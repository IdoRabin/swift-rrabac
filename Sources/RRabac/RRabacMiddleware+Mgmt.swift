//
//  RRabacMiddleware+Mgmt.swift
//  
//
//  Created by Ido on 10/07/2023.
//

import Foundation

public extension RRabacMiddleware /* */ {
    
    func addNewUser(requestorID:MNUID, username:String? = nil, useremail:String? = nil, domain:String? = nil, pwd:String, userInfoId:MNUID? = nil) async -> MNResult<RRabacUser> {
        var result : RRabacUser? = nil
        
        if (username?.count ?? 0) > 0 {
            
        } else if (useremail?.count ?? 0) > 0 {
        } else {
            return .failure(code: .http_stt_created, reason: "Username or email are required")
        }
        
        
        = RRabacUser(username: username, useremail: useremail, domain: domain)
        
        
        return .success(result)
    }
    
    func assocGroupToUser(group:RRabacGroup, user:RRabacUser) {
        
    }
}

