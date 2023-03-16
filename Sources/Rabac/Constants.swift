//
//  File.swift
//  
//
//  Created by Ido on 16/03/2023.
//

import Foundation

#if os(OSX)
    #if VAPOR
        import Vapor
    #endif
#else
    import AppKit
#endif

class RabacDebug {

    public static var IS_DEBUG = false {
        didSet {
            DSLogger.IS_LOGS_ENABLED = Self.IS_DEBUG
        }
    }
    
    static let RESET_DB_ON_INIT = RabacDebug.IS_DEBUG && false // Will wipe
    static let RESET_SETTINGS_ON_INIT = RabacDebug.IS_DEBUG && false
    
    static func StringOrNil(_ str:String)->String? {
        return RabacDebug.IS_DEBUG ? str : nil
    }
    
    static func StringOrEmpty(_ str:String)->String {
        return RabacDebug.IS_DEBUG ? str : ""
    }
}

extension String {
    public static let NBSP = "\u{00A0}"
    public static let FIGURE_SPACE = "\u{2007}" // “Tabular width”, the width of digits
    public static let IDEOGRAPHIC_SPACE = "\u{3000}" // The width of ideographic (CJK) characters.
    public static let NBHypen = "\u{2011}"
    public static let ZWSP = "\u{200B}" // Use with great care! ZERO WIDTH SPACE (HTML &#8203)
    
    public static let SECTION_SIGN = "\u{00A7}" // § Section Sign: &#167; &#xA7; &sect; 0x00A7
    
    public static let CRLF_KEYBOARD_SYMBOL = "\u{21B3}" // ↳ arrow down and right
}

extension Date {
    public static let SECONDS_IN_A_MONTH : TimeInterval = 86400.0 * 7.0 * 4.0
    public static let SECONDS_IN_A_WEEK : TimeInterval = 86400.0 * 7.0
    public static let SECONDS_IN_A_DAY : TimeInterval = 86400.0
    public static let SECONDS_IN_A_DAY_INT : Int = 86400
    public static let SECONDS_IN_AN_HOUR : TimeInterval = 3600.0
    public static let SECONDS_IN_AN_HOUR_INT : Int = 3600
    public static let SECONDS_IN_A_MINUTE : TimeInterval = 60.0
    public static let MINUTES_IN_AN_HOUR : TimeInterval = 60.0
    public static let MINUTES_IN_A_DAY : TimeInterval = 1440.0
}

extension TimeInterval {
    public static let SECONDS_IN_A_MONTH : TimeInterval = 86400.0 * 7.0 * 4.0
    public static let SECONDS_IN_A_WEEK : TimeInterval = 86400.0 * 7.0
    public static let SECONDS_IN_A_DAY : TimeInterval = 86400.0
    public static let SECONDS_IN_A_DAY_INT : Int = 86400
    public static let SECONDS_IN_AN_HOUR : TimeInterval = 3600.0
    public static let SECONDS_IN_AN_HOUR_INT : Int = 3600
    public static let SECONDS_IN_A_MINUTE : TimeInterval = 60.0
    public static let MINUTES_IN_AN_HOUR : TimeInterval = 60.0
    public static let MINUTES_IN_A_DAY : TimeInterval = 1440.0
}

// AppKit / UI Ex additions:
#if !VAPOR
#if os(iOS)
extension NSView {
    var isDarkThemeActive : Bool {
        if #available(OSX 10.14, *) {
            return self.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua, .vibrantDark]) == .darkAqua
        }
        return false
    }
}

func isDarkThemeActive(view: NSView) -> Bool {

    if #available(OSX 10.14, *) {
        return view.isDarkThemeActive
    }
    
    return false
}
#endif
#endif
