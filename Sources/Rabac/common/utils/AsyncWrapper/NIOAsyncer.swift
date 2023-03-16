//
//  NIOAsyncer.swift
//  
//
//  Created by Ido on 16/03/2023.
//

import Foundation

#if VAPOR
import Vapor
import NIO

fileprivate let dlog : DSLogger? = DLog.forClass("NIOAsync")

extension NIODeadline /* delayFromNow : TimeInterval */ {
    static func delayFromNow(_ delay : TimeInterval)->NIODeadline {
        return NIODeadline.now() + .milliseconds(Int64(delay*1000))
    }
}

class NIOAsync : Asyncable, AsyncableExecutor {
    
    private var _tasks : [String:Task<Any, Error>] = [:]
    
    // MARK: Singleton
    public static let shared = NIOAsync()
    private init() {
        
    }
    
    // MARK: Private
    private static func nextEventLoop() throws ->EventLoop {
        let vaporApplication = Self.isInitializing ? globalVaporApplication : AppServer.shared.vaporApplication
        guard let vaporApplication = vaporApplication else {
            dlog?.warning("AppServer.nextEventLoop failed to find vaporApplication or an eventLoop!")
            throw AppError(.misc_failed_creating, reason: "AppServer.nextEventLoop failed to find vaporApplication or an eventLoop!")
        }
        return vaporApplication.eventLoopGroup.next()
    }
    
    
    // MARK: Asyncable
    func performAfter(delay: TimeInterval, block: @escaping () -> Void) {
        
        let deadline = NIODeadline.delayFromNow(delay)
        do {
            return try self.nextEventLoop().scheduleTask(deadline: deadline, task)
        } catch let error {
            do {
                let promise : EventLoopPromise<T> = try self.nextEventLoop().makePromise()
                let sched = Scheduled(promise: promise) {
                    dlog?.warning("scheduleTask<T>(deadline: was canceled!")
                }
                promise.fail(error)
                return sched
            } catch {
                dlog?.warning("scheduleTask<T>(deadline:) failed creaing a schedulaed task!")
            }
        }
        
        preconditionFailure("scheduleTask<T>(deadline:) failed creaing a schedulaed task!")
    }
    
    func performOnce(uniqueToken: String, persistSessions:Bool, block: () -> Void) -> Bool {
        
    }
    
    func performOncePerInstance(_ instance: Any, block: () -> Void) -> Bool {
        
    }
    
    func performOncePerSession(block: () -> Void) -> Bool {
        
    }
    
    func performOncePerInstall(token: String, forAnyQueue: Bool, isDebugIgnore: Bool, block: () -> Void) -> Bool {
        
    }
    
    func debounce(delay: TimeInterval, execOption: AsyncExecOption, block: @escaping () -> Void) {
        
    }
}

#endif
