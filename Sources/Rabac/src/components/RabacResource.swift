//
//  File.swift
//  
//
//  Created by Ido on 01/03/2023.
//

import Foundation

fileprivate let dlog : DSLogger? = DLog.forClass("RabacElement")?.setting(verbose: false)


class RabacResource : RabacElement {
    // MARK: Const
    // MARK: Static

    // MARK: Public
    var rabacRoute : RabacRoute? {
        return self.rabacId.title.rabacRoute
    }
    
    var isMask : Bool {
        return self.rabacIdString.contains(anyOf: [], isCaseSensitive: false)
    }
}
