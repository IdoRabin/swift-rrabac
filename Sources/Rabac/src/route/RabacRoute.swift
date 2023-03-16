//
//  RabacRoute.swift
//  
//
//  Created by Ido on 05/03/2023.
//

import Foundation

fileprivate let dlog : DSLogger? = DLog.forClass("RabacRoute")?.setting(verbose: false)

struct RabacRoute : RabacResourceMatcher, LosslessStringConvertible {
    
    let components : [RabacRouteComponent]
    
    // MARK: LosslessStringConvertible
    var description: String {
        return self.components.compactMap { comp in
            comp.description
        }.joined(separator: RabacRouteConsts.MAIN_PATH_DELIM).prefixedOnce(with: RabacRouteConsts.MAIN_PATH_DELIM)
    }
    
    init?(_ description: String) {
        self.components = description.rabacRouteComponents
    }
    
    init?(components newComps : [RabacRouteComponent]) {
        guard newComps.count > 0 else {
            dlog?.warning("RabacRoute init?(components:) had 0 elements in the input components array.")
            return nil
        }
        self.components = newComps
    }
    
    // MARK: RabacResourceMatcher
    var rabacRoute: RabacRoute? {
        return self
    }
}

typealias RabacRouteMatchResult = Result<String, RabacError>

protocol RabacResourceMatcher {
    
    var rabacRoute: RabacRoute? { get }
    
    func matchesRoute(_ route : RabacRoute)->RabacRouteMatchResult
}

extension RabacResourceMatcher /* default implenmentation */ {
    
    static func extractComponents(_ element:Any)->[RabacRouteComponent]? {
        var comps : [RabacRouteComponent] = []
        if comps.count == 0 {
            comps = (element as? RabacRoute)?.components ?? []
        }
        if comps.count == 0 {
            comps = (element as? String)?.asNormalizedPathOnly().rabacRouteComponents ?? []
        }
        
        #if VAPOR
        // init (_ pc: RoutingKit.PathComponent) {
        if comps.count == 0 {
            comps = (self as? [RoutingKit.PathComponent])?.compactMap({ pathComp in
                return RabacRouteComponent(pathComponent:pathComp)
            })
        }
        #endif
        
        if comps.count == 0 {
            return nil
        }
        
        return comps
    }
    
    // Base func (the actual logic)
    static func matchRouteComponents(matcherComp : [RabacRouteComponent], resourceComp : [RabacRouteComponent])->RabacRouteMatchResult {
        let minW = min(matcherComp.count, resourceComp.count)
        guard minW > 0 else {
            let msg = ".matchRouteComponents(_:) had at least one empty component \(matcherComp.descriptionsJoined)"
            dlog?.verbose(log: .note, msg)
            return .failure(.init(code: .misc_failed_validation, reason: msg))
        }
        guard matcherComp.isValid && resourceComp.isValid else {
            let msg = "matchRouteComponents(_:) matcher path or resource path are invalid!"
            dlog?.verbose(log: .warning, msg)
            return .failure(.init(code: .misc_failed_validation, reason: msg))
        }
            
        var isRequiresSameCount = matcherComp.isRequiresSameCompCount
        
        // NOTE: .catchall allows all subpath component count ONLY when it is the last path component: otherwise will validate the rout path has the same amount of path components as the matcher components
        if matcherComp.contains(elementEqualTo: .anything) {
            isRequiresSameCount = true
        }
        if matcherComp.contains(elementEqualTo: .catchall) {
            isRequiresSameCount = (matcherComp.lastIndex(of: .catchall) ?? Int.max) < matcherComp.count - 1
        }
        
        if isRequiresSameCount && matcherComp.count != resourceComp.count {
            // Requires matcher to have more or equal components count than the resource path
            let msg = "matchRouteComponents(_:) Requires matcher to have more or equal components count than the resource path. (isRequiresSameCount) matcher: \(matcherComp.descriptionsJoined) != route: \(resourceComp.descriptionsJoined)"
            dlog?.verbose(log: .warning, msg)
            return .failure(.init(code: .misc_failed_validation, reason: msg))
        }
        
        // Path Components matching between the full path and a matcher:
        var result : RabacRouteMatchResult = .success("matchRouteComponents(matcherComp:resourceComp) success")
        // .failure(.init(code: .misc_failed_validation, reason: "Unknwon reason matchRouteComponents(matcherComp:resourceComp)"))
        
        for index in 0..<minW {
            let mtcComp = matcherComp[index]
            let rscComp = resourceComp[index]
            
            let matchResult = mtcComp.matches(other: rscComp, fullPath: resourceComp.fullPath.asNormalizedPathOnly())
            if matchResult.isFailed, let error = matchResult.errorValue {
                result = .failure(error as! RabacError)
                dlog?.verbose(log:.fail,        ".matchRouteComponents(_:)  failed matching: \(mtcComp) with \(rscComp) ❌ error: \(error.description)")
                break
            } else {
                dlog?.verbose(log:.success,     ".matchRouteComponents(_:) success matching: \(mtcComp) with \(rscComp) ✅")
            }
        }
        
        // Catchall that is not the last path component does not allow any depth
        if result.isSuccess && matcherComp.contains(elementEqualTo: .catchall) {
            let lastCatchall : Int = matcherComp.lastIndex(of: .catchall) ?? 0
            if lastCatchall < matcherComp.count - 1 &&
                resourceComp.count > minW {
                result = .failure(.init(code: .misc_failed_validation, reason: "Catchall that is not the last path component does not allow any depth"))
            }
        }
        
        
        if result.isSuccess {
            dlog?.success(".matchRouteComponents(_:)   END \(matcherComp.fullPath) | \(resourceComp.fullPath) SUCCESS")
        } else {
            dlog?.verbose(log: .fail, ".matchRouteComponents(_:)   END \(matcherComp.fullPath) | \(resourceComp.fullPath) SUCCESS")
        }
        //
        return result
    }
    
    // Convenience funcs
    static func matchesRoutes(route1 : RabacRoute, route2 : RabacRoute)->RabacRouteMatchResult {
        guard let comps1 = Self.extractComponents(route1), comps1.count > 0 else {
            let msg = "RabacResourceMatcher \(Self.self).matchesRoute(route:\(route1.description) failed casting to components or had 0 elements."
            dlog?.warning(msg)
            return .failure(.init(code: .misc_failed_validation, reason: msg))
        }
        
        guard let comps2 = Self.extractComponents(route2), comps2.count > 0 else {
            let msg = "RabacResourceMatcher \(Self.self).matchesRoute(route:\(route2.description) failed casting to components or had 0 elements."
            dlog?.warning(msg)
            return .failure(.init(code: .misc_failed_validation, reason: msg))
        }
        
        return Self.matchRouteComponents(matcherComp: comps1, resourceComp: comps2)
    }
    
    func matchesRoute(_ route2 : RabacRoute)->RabacRouteMatchResult {
        if let route1 = self.rabacRoute {
            return Self.matchesRoutes(route1:route1 , route2: route2)
        } else if let route1 = self as? RabacRoute {
            return Self.matchesRoutes(route1:route1 , route2: route2)
        } else if let routes = self as? [RabacRouteComponent], let route1 = RabacRoute(components: routes) {
            return Self.matchesRoutes(route1:route1 , route2: route2)
        } else if let routesstrs = self as? [String], let route1 = routesstrs.rabacRoute {
            return Self.matchesRoutes(route1:route1 , route2: route2)
        } else if let routeStr = self as? String, let route1 = RabacRoute(routeStr) {
            return Self.matchesRoutes(route1:route1 , route2: route2)
        } else {
            dlog?.note("\(Self.self).matchesRoute(_ route : RabacRoute) did not implement handling of : \(type(of: self))")
        }
        
        return .failure(.init(code: .misc_failed_validation, reason: "matchesRoute(_:) failed matching \(type(of: self)) : route: \(route2.components.fullPath.asNormalizedPathOnly())"))
    }
}

extension String /* RabacRouteComponents */ {
    
    var pathComponents : [String] {
        guard let cleanedStr = self.components(separatedBy: "?").first?.components(separatedBy: ",").first?.components(separatedBy: "#").first else {
            return [] // empty
        }
        
        let comps = cleanedStr.trimming(string: RabacRouteConsts.MAIN_PATH_DELIM).components(separatedBy: RabacRouteConsts.MAIN_PATH_DELIM)
        return comps.compactMap { str in
            str.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    var rabacRouteComponents : [RabacRouteComponent] {
        let comps = self.pathComponents
        
        guard comps.count > 0 else {
            return [] // empty
        }
        
        return comps.compactMap { comp in
            return RabacRouteComponent(comp)
        }
    }
    
    
    /// Create a RabacRoute for the string assuming the String contains a path
    var rabacRoute : RabacRoute? {
        return RabacRoute(components: self.rabacRouteComponents)
    }
}

extension Sequence where Element == String {
    var fullPath : String {
        return self.joined(separator: "/") // path delimiter
    }
    
    var rabacRoute : RabacRoute? {
        guard let comps = self.rabacRouteComponents else {
            return nil
        }
        
        return RabacRoute(components: comps)
    }
    
    var rabacRouteComponents : [RabacRouteComponent]? {
        var result : [RabacRouteComponent] = []
        
        for comp in self {
            let comps = comp.rabacRouteComponents
            result.append(contentsOf: comps)
        }
        
        if result.count == 0 {
            return nil
        }
        return result
    }
}
