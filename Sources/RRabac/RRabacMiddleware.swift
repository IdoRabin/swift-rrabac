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

public protocol RRabacModel : Model & Content & MNUIDable & AsyncResponseEncodable & Migration {
    var migrationName : String  { get }
}

public extension RRabacModel {
    var migrationName : String {
        return "\(type(of:self))".trimmingCharacters(in: .punctuationCharacters)
    }
}

public extension Sequence where Element : RRabacModel {
    
    var migrationNames : [String] {
        return self.compactMap { migration in
            return migration.migrationName
        }
    }
    
    var shortMigrationNames : [String] {
        return self.compactMap { migration in
            return migration.name.split(separator: ".", maxSplits: 1).suffix(from: 1).joined(separator: ".")
        }
    }
}

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
    deinit {
        dlog?.info("deinit")
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
            RRabacRole(),
            RRabacPermissionResult(),
            RRabacUser(),
            
            // RRabac complex models:
            RRabacGroup(),
            
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
        dlog?.info("willBoot")
    }
    
    public func didBoot(_ application: Application) throws {
        dlog?.info("didBoot")
    }
    
    public func shutdown(_ application: Application) {
        dlog?.info("shutdown")
    }
    
    public func boot(_ app: Vapor.Application) throws {
        dlog?.info("boot")
    }
}

extension RRabacMiddleware : MNBootStateObserver {
    
    public typealias ObjectType = Vapor.Route
    
    public func willBoot<App>(object: ObjectType, inApp app: App?) where App : AnyObject {
        dlog?.info("app willBoot: \(app.descOrNil)")
    }
    
    public func didBoot<App>(object: ObjectType, inApp app: App?) where App : AnyObject {
        dlog?.info("app didBoot: \(app.descOrNil)")
    }
    
    public func willShutdown<App>(object: ObjectType, inApp app: App?) where App : AnyObject {
        dlog?.info("app willShutdown: \(app.descOrNil)")
    }
    
    public func didShutdown<App>(object: ObjectType, inApp app: App?) where App : AnyObject {
        dlog?.info("app didShutdown: \(app.descOrNil)")
    }
    
    
    
    
}
