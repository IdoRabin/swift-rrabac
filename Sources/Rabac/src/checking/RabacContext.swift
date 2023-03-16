//
//  RabacContext.swift
//  Rabac
//
//  Created by Ido on 01/03/2023.
//

import Foundation

typealias RabacContext = [RabacContextKey:Any]

extension RabacContext {
    var person : AnyRababcPerson? { get { self[.actor] as? AnyRababcPerson } }
    var urlRequest : URLRequest? { get { self[.request] as? URLRequest } }
    var checkParams : [RabacID:  /* info / params */ String]? { get { return self[.checkableParams] as? [RabacID:String] } }
}

#if VAPOR
extension RabacContext /* Vapor */ {
    var vaporRequest : Vapor.Request? { get { self[.request] as? Vapor.Request } }
    
    var fullRequestPath : String? {
        if let url = vaporRequest?.url.string ?? urlRequest?.url?.absoluteString {
            return url.asNormalizedPathOnly()
        }
        return nil
    }
}
#endif
