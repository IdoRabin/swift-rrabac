//
//  File.swift
//  
//
//  Created by Ido on 16/03/2023.
//

import Foundation
import Dispatch

fileprivate let dlog : DSLogger? = DLog.forClass("GDCAsync")

class GDCAsync : AsyncableExecutor {
    // MARK: Singleton
    public static let shared = GDCAsync()
    private init() {
        
    }
    
    static let main = GDCAsyncer(.main)
    static let global = GDCAsyncer(.global)
}

class GDCAsyncer : Asyncable {
    
    enum SType {
        case global
        case main
    }
    
    private var _tasks : [String:Task<Any, Error>] = [:]
    private var _stype : SType = .main
    
    // MARK: Private
    fileprivate init(_ stype:SType) {
        self._stype = stype
    }
    
    fileprivate func getQueue()->DispatchQueue? {
        switch self._stype  {
        case .global:   return DispatchQueue.global(qos: .default)
        case .main:     return DispatchQueue.main
        }
        // return nil
    }
    
    // MARK: Asyncable
    func performAfter(delay: TimeInterval, block: @escaping () -> Void) {
        guard let queue = self.getQueue() else {
            dlog?.warning("Failed getting a dispatchQueue for performAfter(delay: TimeInterval)..")
            return
        }
        
        queue.asyncAfter(deadline: T##Dispatch.DispatchTime, execute: T##Dispatch.DispatchWorkItem)
    }
    
    func performOnce(uniqueToken: String, persistSessions:Bool, block: () -> Void) -> Bool {
        
    }
    
    func performOncePerInstance(_ instance: Any, block: () -> Void) -> Bool {
        
    }
    
    func performOncePerSession(block: () -> Void) -> Bool {
        
    }
    
    func performOncePerInstall(token: String, forAnyQueue: Bool, isDebugIgnore: Bool, block: () -> Void) -> Bool {
        
    }
    
    func debounce(delay: TimeInterval, uniqueKey:String? = nil, execOption: AsyncExecOption, block: @escaping () -> Void) {
        
    }
}
