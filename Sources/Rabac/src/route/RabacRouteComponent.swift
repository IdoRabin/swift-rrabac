//
//  File.swift
//  
//
//  Created by Ido on 07/03/2023.
//

import Foundation

fileprivate let dlog : DSLogger? = DLog.forClass("RabacRouteComponent")


// RoutingKit's PathComponent on seteroids:
/// A single path component of a `Route`. An array of these components describes
/// a route's path, including which parts are constant and which parts are dynamic.
///  NOTES:
///  ** Catchall ** that is not the last path component does NOT allow any depth
///  ** Catchall ** that is the only / last path component does allow any depth
///     
enum RabacRouteComponent : LosslessStringConvertible, Equatable, Codable {
    
    enum Simplified : Int, Equatable, Codable {
        case constant = 1
        case parameter = 2
        case regex = 3
        case anything = 4
        case catchall = 5
    }
    
    case constant(String)
    case parameter(String)              /// Represented as `:` followed by the identifier.
    case regex(String)                  /// Represented as containing at least one ^
    case anything                       /// Represented as `*` // cathes anything in this path level
    case catchall                       /// Represented as `**` // catches anything incl. longer paths
    
    #if VAPOR
    init (pathComponent: RoutingKit.PathComponent) {
        // description ? rawValue ? String(describing:pc) ?
        if let pcs = pathComponent.description as? String, pcs.contains(Self.REGEX) {
            self = .regex(pcs)
        } else {
            switch pc {
            case constant(let pth): self = .constant(pth)
            case parameter(let prm): self = .parameter(pth)
            case anything: self = .anything
            case catchall: self = .catchall
            }
        }
    }
    #endif
    
    /// `LosslessStringConvertible, ExpressibleByStringLiteral` conformance.
    init?(_ description: String) {
        guard description.count > 0 else {
            return nil
        }
        
        if description == RabacRouteConsts.CATCHALL {
            self = .catchall
        } else if description == RabacRouteConsts.ANYTHING {
            self = .anything
        } else if description.hasPrefix(RabacRouteConsts.PARAMPREFIX) {
            self = .parameter(.init(description.dropFirst()))
        } else if description.contains(RabacRouteConsts.REGEX) {
            self = .regex(description)
        } else {
            self = .constant(description)
        }
    }
    
    var description : String {
        switch self {
        case .catchall:             return RabacRouteConsts.CATCHALL
        case .constant(let const):  return const
        case .parameter(let prm):   return prm.prefixedOnce(with: RabacRouteConsts.PARAMPREFIX)
        case .regex(let rgx):       return rgx
        case .anything:             return RabacRouteConsts.ANYTHING
        }
    }
    
    var pathStringsOnly : String {
        switch self {
        case .catchall:             return ""
        case .constant(let const):  return const
        case .parameter(let prm):   return prm.trimming(string: RabacRouteConsts.PARAMPREFIX)
        case .regex:                return ""
        case .anything:             return ""
        }
    }
 
    var simplified : Simplified {
        switch self {
        case .constant:    return .constant
        case .parameter:   return .parameter
        case .regex:       return .regex
        case .anything:    return .anything
        case .catchall:    return .catchall
        }
    }
    
    static func match(matcherComp:RabacRouteComponent, resComp:RabacRouteComponent, fullPath:String)->RabacRouteMatchResult {
        var mc = matcherComp
        var rc = resComp
        
        // Both comps have exactly the same raw value:
        if matcherComp.simplified.rawValue < resComp.simplified.rawValue {
            mc = resComp
            rc = matcherComp
        }
        
        var result : RabacRouteMatchResult = .failure(RabacError(code: .misc_failed_parsing, reason: "match(matcherComp:resComp) failed for an unknown reason"))
                                                      
        if mc == rc {
            // Both comps have exactly the same value:
            result = .success("constants: OK")
        } else if (matcherComp.simplified != .constant && resComp.simplified != .constant) {
            // Matching required one comp to be .constant()
            result = .failure(RabacError(code: .misc_failed_validation, reason: "match(comp1:\(matcherComp), comp2:\(resComp)) requires that one of the components is .constant!"))
        } else {
            let resStr = resComp.description // we know that comp1.simplified == .constant, so str1 is always
            
            switch matcherComp {
            case .constant: // (let str2):
                let matcherStr = matcherComp.description
                if matcherStr.compare(resStr, options: .caseInsensitive) == .orderedSame {
                    result = .success("constants: OK")
                } else {
                    result = .failure(.init(code: .misc_failed_validation,
                                            reason: "constant params: \(matcherStr) and \(resStr) were expected to be Equal (case insensitive)."))
                }
            case .parameter(let paramTypeStr):
                
                result = RabacMgr.shared.isPathParamValid(paramTypeStr: paramTypeStr, paramVal: resStr, fullPath: fullPath)
                
            case .regex(let expression):
                do {
                    let expr = try Regex(expression)
                    if try expr.firstMatch(in: resStr) != nil {
                        result = .success("regex: matched regex '\(expression)' to '\(resStr)'")
                    } else {
                        result = .failure(.init(code: .misc_failed_validation,
                                                reason: "Component '\(resStr)' failed validation vs. regex: '\(expression)'"))
                    }
                } catch let error {
                    result = .failure(.init(code: .misc_failed_validation,
                                            reason: "match(comp1:comp2) failed creating an instance for Regex '\(expression)'. raised an Exception : \(error.description) (cannot check if matches param: \(resStr)"))
                }
                
            case .anything:
                result = .success("anything")
                
            case .catchall:
                
                result = .success("catchall")
            }
        }
        
        return result
    }
    
    func matches(other:RabacRouteComponent, fullPath:String)->RabacRouteMatchResult {
        return Self.match(matcherComp: self, resComp: other, fullPath: fullPath)
    }
}


extension Array where Element == RabacRouteComponent {
    var fullPath : String {
        return self.compactMap { comp in
            let res = comp.description
            if res.count > 0 {
                return res
            }
            return nil
        }.joined(separator: RabacRouteConsts.MAIN_PATH_DELIM)
    }
    
    
    /// Does the matcher path (assuming it is not all .constants)  requires the route path to have the exact same component count (i.e /my/*/*/path will require 4 components, such as "/my/x/y/path" but will not allow "my/x/y/path/extra", and will not alow "my/x/path")
    var isRequiresSameCompCount : Bool {
        var result = true
        if self.last == .catchall {
            result = false
        }
        return result
    }
    
    var isValid : Bool {
        let result = true
        
        // TODO: Add validation rules for matchers and paths...
        /*
        let catchalls = self.filter({ comp in
            comp == .catchall
        })
        let anythings = self.filter({ comp in
            comp == .anything
        })
          */
        return result
    }
    
}
