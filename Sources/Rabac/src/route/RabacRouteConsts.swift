//
//  RabacRouteConsts.swift
//  
//
//  Created by Ido on 07/03/2023.
//

import Foundation

// Constants used by RabacRoute and RabacRouteComponents
// Some items are the same as those used by PathComponents in NIO or Vapor:
class RabacRouteConsts {
    static let MAIN_PATH_DELIM = "/"
    static let PATH_DELIMS = [MAIN_PATH_DELIM, "?", "#"]
    
    static let ANYTHING = "*"
    static let PARAMPREFIX = ":"
    static let CATCHALL = "**"
    static let REGEX = "^"
}
