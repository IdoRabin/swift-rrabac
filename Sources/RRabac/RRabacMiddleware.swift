//
//  RRabac.swift
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

fileprivate let dlog : DSLogger? = DLog.forClass("RRabacMiddleware")

public enum RRabacPermissionSubject : JSONSerializable, Hashable {
    case users([MNUID])
    case files([String])
    case routes([String])
    case webpages([String])
    case models([String])
    case commands([String])
    case underermined
}

public protocol RRabacPermissionGiver {
    
    func isAllowed(for selfUser:RRabacUser?,
                   to action:AnyCodable,
                   on subject:RRabacPermissionSubject?,
                   during req:Request?,  
                   params:[String:Any]?)->RRabacPermission
}

public typealias IsVaporRequestResult = MNResult<Bool /*, MNError */>
public typealias IsVaporRequestSomeTestBlock = (_ request: Vapor.Request)->IsVaporRequestResult

final public class RRabacMiddleware: Middleware, LifecycleBootableHandler {
    
    public typealias RResponse = NIOCore.EventLoopFuture<Vapor.Response>
    private var errorWebpagePaths = Set<String>()
    
    // MARK: Lifecycle
    init(env:Environment, errorWebpagePaths: Set<String>, errPageCheck : IsVaporRequestSomeTestBlock? = nil) {
        self.errorWebpagePaths = errorWebpagePaths
        self.isErrorPageNoPermissionNeeded = errPageCheck ?? {(_ request: Vapor.Request) -> IsVaporRequestResult in
            let urlPath = request.url.asNormalizedPathOnly()
            var result : IsVaporRequestResult = .failure(MNError(code:.misc_unknown, reason: "Failed detecting if \(urlPath) is an error page."))
            if errorWebpagePaths.containsSubstring(urlPath) {
                result = .success(true)
            }
            if errorWebpagePaths.containsSubstring(urlPath) {
                result = .success(true)
            }
            
            return result
        }
    }
    
    // MARK: Public Properties
    public var isErrorPageNoPermissionNeeded : IsVaporRequestSomeTestBlock = {(_ request: Vapor.Request) -> IsVaporRequestResult in
        return  .success(true)
    }
    
    // MARK: Public
    public func respond(to request: Vapor.Request, chainingTo next: Vapor.Responder) -> RResponse {
        
        func skip()->RResponse {
            return next.respond(to: request)
        }
        
        // Skip if the page / route is of an error page / no permissions needed
        let isErrPg = isErrorPageNoPermissionNeeded(request)
        if isErrPg.isSuccess {
            return skip()
        }
        
        
        let promise = request.eventLoop.makePromise(of: Vapor.Response.self)
        //
        
        
        return promise.futureResult
    }
    
    public struct Config {
        public let errorWebpagePaths : [String]
    }
}

public extension RRabacMiddleware {
    
}
