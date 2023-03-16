//
//  CachesHelper.swift
//  Bricks
//
//  Created by Ido on 01/12/2021.
//  Copyright © 2022 Bricks Ltd. All rights reserved.
//

import Foundation

fileprivate let dlog : DSLogger? = DLog.forClass("CachesHelper")

class CachesHelper : NSObject {
    var observers = ObserversArray<CachesEventObserver>()
    
    // MARK: Singleton
    public static let shared = CachesHelper()
    
    // MARK: Lifecycle
    override private init(){
        super.init()
        //AppEventsManager.shared.observers.addObserver(self)
    }
    
    deinit {
        //AppEventsManager.shared.observers.removeObserver(self)
    }
    
    // MARK: Debugging
//    func debugLogCachNamesAndCapacicites() {
//        self.observers.enumerateOnMainThread { (observer) in
//            if let cache = observer as? AnyCache {
//                dlog?.info("cache: [\(cache.name)] contains: \(cache.count) / \(cache.maxSize)")
//            }
//        }
//    }
}

protocol CachesEventObserver {
    func applicationDidReceiveMemoryWarning(_ application: Any)
}

//extension CachesHelper : AppEventsObserver {
//
//    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
//        dlog?.info("applicationDidReceiveMemoryWarning:")
//        self.debugLogCachNamesAndCapacicites()
//        observers.enumerateOnMainThread { (observer) in
//            observer.applicationDidReceiveMemoryWarning(application)
//        }
//    }
//}

extension CachesHelper : CacheObserver {
    
    
    func cacheWasLoaded(uniqueCacheName: String, keysCount: Int, error: CacheError?) {
        // ?
    }
    
    func cacheItemsUpdated(uniqueCacheName: String, updatedItems: [AnyHashable : Any]) {
        // ?
    }
    
    
    func cacheItemUpdated(uniqueCacheName: String, key: Any, value: Any) {
        // ?
    }
    
    func cacheWasCleared(uniqueCacheName: String) {
        // ?
    }
    
    func cacheItemsWereRemoved(uniqueCacheName: String, keys: [Any]) {
        // ?
    }
    
}
