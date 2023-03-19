//
//  MNProgress.swift
//  
//
//  Created by Ido on 18/03/2023.
//


import Foundation

fileprivate let dlog : DSLogger? = DLog.forClass("MNProgress")

protocol MNFractionProgressable : Hashable, Equatable, Codable {
    var fractionCompleted : Double { get }
    var fractionCompletedDisplayString : String { get }
    func fractionCompletedDisplayString(decimalDigits:UInt)->String
    
    var isEmpty : Bool { get }
    var isCompleted : Bool { get }
}

extension MNFractionProgressable {
    var fractionCompletedDisplayString : String {
        return fractionCompletedDisplayString(decimalDigits: 0)
    }
    
    func fractionCompletedDisplayString(decimalDigits:UInt = 0)->String {
        return MNProgress.progressFractionCompletedDisplayString(fractionCompleted: self.fractionCompleted, decimalDigits: decimalDigits)
    }
    
    // MARK: hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(fractionCompleted)
    }
    
    var isEmpty : Bool {
        return fractionCompleted == 0.0
    }
}
struct MNProgress {
    
    // MARK: Const
    // MARK: Static
    // MARK: Properties / members
    
    // MARK: Static funcs
    /// returns a formatted percentage display string (0% - 100%) for a given progress fraction, with required decimal digit accuracy in the string.
    /// - Parameters:
    ///   - fractionCompleted: fraction in the range of 0.0 ... 1.0 (othe values will be clamped)
    ///   - decimalDigits: amount of decimal digits in the resulting string, clamped to 0...12 digits.
    /// - Returns: a string in the format of "100.0%" (or however many decimal digits required)
    static func progressFractionCompletedDisplayString(fractionCompleted: Double, decimalDigits:UInt = 0)->String {
        let fraction = clamp(value: fractionCompleted, lowerlimit: 0.0, upperlimit: 1.0) { val in
            dlog?.note("progressFractionCompletedDisplayString fraction out of bounds, \(val) should be between [0.0...1.0]")
        }
        
        if decimalDigits == 0 {
            return String(format: "%d%%", clamp(value: Int(fraction * 100), lowerlimit: Int(0), upperlimit: Int(100)))
        } else {
            return String(format: "%0.\(clamp(value: decimalDigits, lowerlimit: 1, upperlimit: 12))f%%", clamp(value: Int(fraction * 100), lowerlimit: 0, upperlimit: 100))
        }
    }
    
    // MARK: Private
    // MARK: Lifecycle
    // MARK: Public
}
