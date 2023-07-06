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

fileprivate let dlog : DSLogger? = DLog.forClass("RRabacMiddleware")?.setting(verbose: true)

typealias RRabacModel = Model & Content & MNUIDable & AsyncResponseEncodable & Migration
public typealias IsVaporRequestResult = MNResult<Bool /*, MNError */>
public typealias IsVaporRequestSomeTestBlock = (_ request: Vapor.Request)->IsVaporRequestResult

final public class RRabacMiddleware: Middleware {
    
    public typealias RResponse = NIOCore.EventLoopFuture<Vapor.Response>
    private var config : Config!
    
    // MARK: Public Properties
    public var isErrorPageNoPermissionNeeded : IsVaporRequestSomeTestBlock = {(_ request: Vapor.Request) -> IsVaporRequestResult in
        return .success(true)
    }
    
    public struct Config {
        public let env : Environment
        public let errorWebpagePaths : Set<String>
        public let errorPageCheck : IsVaporRequestSomeTestBlock?
        public let debugAllowAll : Bool
    }
    
    // MARK: Lifecycle
    private init(config:Config) {
        self.config = config
        self.isErrorPageNoPermissionNeeded = config.errorPageCheck ?? {(_ request: Vapor.Request) -> IsVaporRequestResult in
            let urlPath = request.url.asNormalizedPathOnly()
            var result : IsVaporRequestResult = .failure(MNError(code:.misc_unknown, reason: "Failed detecting if \(urlPath) is an error page."))
            guard config.errorWebpagePaths.containsSubstring(urlPath) == false else {
                return .failure(MNError(code: .misc_no_permission_for_operation, reason: "Failed detecting if \(urlPath) is an error page. (paths checked)"))
            }
            
            dlog?.verbose("isErrorPageNoPermissionNeeded")
            return result
        }
        
        dlog?.verbose("Init w/ errorPages: \(config.errorWebpagePaths.descriptionsJoined)")
    }
    
    // MARK: Public
    public func respond(to request: Vapor.Request, chainingTo next: Vapor.Responder) -> RResponse {
        
        func skip()->RResponse {
            return next.respond(to: request)
        }
        
        if config.debugAllowAll && MNUtils.debug.IS_DEBUG {
            return skip()
        }
        
        // Skip if the page or route is of an error page / no permissions needed
        let isErrPg = isErrorPageNoPermissionNeeded(request)
        if isErrPg.isSuccess {
            return skip()
        }
        
        
        let promise = request.eventLoop.makePromise(of: Vapor.Response.self)
        //
        
        
        return promise.futureResult
    }
    
    //  MARK: Static funcs
    public static func Configured (
        env:Environment,
        errorWebpagePaths : [String],
        errorPageCheck : IsVaporRequestSomeTestBlock?
    )->RRabacMiddleware {
        return RRabacMiddleware(config: Config(env: env,
                                               errorWebpagePaths: Set(errorWebpagePaths),
                                               errorPageCheck: errorPageCheck,
                                               debugAllowAll: true))
    }
}

public extension RRabacMiddleware /* + Fluent */ {
    func allMigrations()->[Migration] {
        let result : [Migration] = [
            // RRabac classes / models:
            RRabacHitsoryItem(),
            RRabacPermission(),
            RRabacPermissionResult(),
            RRabacRole(),
            RRabacUser(),
            
            // Cross-table
            RRabacRoleGroup(),
            RRabacRolePermission(),
            RRabacUserRole(),
            RRabacUserGroup(),
        ]
        
        return result
    }
}

// MARK: LifecycleBootableHandler
extension RRabacMiddleware : LifecycleBootableHandler {
    
    public func willBoot(_ application: Application) throws {
        
    }
    
    public func didBoot(_ application: Application) throws {
        
    }
    
    public func shutdown(_ application: Application) {
        
    }
    
    public func boot(_ app: Vapor.Application) throws {
        
    }
}
