//
//  RabacContextKey.swift
//  Rabac
//
//  Created by Ido on 02/03/2023.
//

import Foundation

// Keys for RabacContext
enum RabacContextKey : String, Codable, Equatable {
    case accessToken = "access_token" // The current request's access token
    case actor = "actor" // Usually a User or any RabacPerson
    case action = "action" // HTTPMethod or other kinds of actions. ( GET a page, POST, url request, db query)
    case requestedResource = "req_resource" // all api / webpage route paths, public filenames, elements from db
    case request = "req" // Vapor.Request or URLRequest
    case resourceOwner = "resource_owner" // Owner of the wanted resource
    case requestedResourceType = "req_resource_type"
    case checkableParams = "chk_params" // The parameters assigned to the current check (RabacCheckable)
}
