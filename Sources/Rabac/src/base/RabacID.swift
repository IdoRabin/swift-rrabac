//
//  RabacName.swift
//  
//
//  Created by Ido on 01/03/2023.
//

import Foundation


protocol RabacIdentifiable : LosslessStringConvertible, Codable, Hashable, Equatable {
    var title : String { get }
    var type : RabacType  { get }
    
    func isTitleMatches(expression:String)->Bool
}

/// Id that is easily human readable and hashable
struct RabacID : RabacIdentifiable {
    
    static private let REQUIRED_NAME_LENGTH  = 4...62 // Range
    static private let DELIMITERS_STRING = ".-_/:*|"
    static private let DELIMITERS_CHAR_SET = CharacterSet(charactersIn:DELIMITERS_STRING)
    static private let ALLOWED_CHARS = CharacterSet.latinAlphabet.union(.latinDigits).union(DELIMITERS_CHAR_SET)
    static private let DISALLOWED_DELIMS_CHAR_SET = ALLOWED_CHARS.inverted
        
    init?(_ description: String) {
        let comps = description.components(separatedBy: Self.DELIMITERS_CHAR_SET)
        guard comps.count >= 2 else {
            return nil
        }
        
        self.type  = RabacType(comps[0])!
        self.title = comps[1]
    }
    
    var description: String {
        return  "\(type.rawValue).\(title)"
    }
    
    let title : String
    let type : RabacType
    
    // MARK: Coding / Codable
    enum CodingKeys: String, CodingKey {
        case idtitle = "id_title"
        case idtype = "id_type"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .idtitle)
        self.type = try container.decode(RabacType.self, forKey: .idtype)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.title, forKey: .idtitle)
        try container.encode(self.type, forKey: .idtype)
    }
    
    static func sanitizeTitle(_ input:String)->String {
        var sanitized = input.trimmingCharacters(in: .whitespacesAndNewlines).asNormalizedPathOnly()
        sanitized = sanitized.replacingOccurrences(of: Self.DISALLOWED_DELIMS_CHAR_SET, with: "_")
        return sanitized
    }
    
    init(type:RabacType, title:String) {
        let sanitizedTitle = Self.sanitizeTitle(title)
        precondition(Self.REQUIRED_NAME_LENGTH.contains(sanitizedTitle.count),
                     "RabacName [\(type.rawValue).\(sanitizedTitle)] must contain \(Self.REQUIRED_NAME_LENGTH) charachters in the title part.")
        precondition(sanitizedTitle.components(separatedBy: Self.DISALLOWED_DELIMS_CHAR_SET).count <= 1,
                     "RabacName [\(type.rawValue).\(sanitizedTitle)] may only contain latin alphabet, digits and the chars \(Self.DELIMITERS_STRING).")
        
        self.type = type
        self.title = sanitizedTitle
    }
    
    // MARK: Equatable
    static func ==(lhs:RabacID, rhs:RabacID)->Bool {
        return lhs.type == rhs.type && lhs.title == rhs.title
    }
    
    func isTitleMatches(expression:String)->Bool {
        guard expression != title else {
            return true
        }
        
        // Check as path expression
        
        
        // Check as regex
        
        return false
    }
}

extension Sequence where Element : RabacIdentifiable {
    
    var titles : [String] {
        return self.map { $0.title }.uniqueElements()
    }
    
    var types : [RabacType] {
        return self.map { $0.type }.uniqueElements()
    }
    
    var isHomogenousType : Bool {
        return (self.types.count <= 1)
    }
    
    private func _filterExp(_ rid: any RabacIdentifiable,types:[RabacType]?, expressions:[String])->Bool {
        // If types mask was specified
        if let types = types, !types.contains(rid.type) {
            return false
        }
        
        for expression in expressions {
            if expression.count > 0 && rid.isTitleMatches(expression: expression) {
                return true
            }
        }
        
        return false
    }
    
    func firstMatching(types:[RabacType]?, expressions:[String])->Element? {
        guard expressions.count > 0 else {
            return nil
        }
     
        return self.first { rid in
            return self._filterExp(rid, types: types, expressions: expressions)
        }
    }
    
    func filterMatching(types:[RabacType]?, expressions:[String])->[Element] {
        guard expressions.count > 0 else {
            return []
        }
        
        return self.filter { rid in
            return self._filterExp(rid, types: types, expressions: expressions)
        }
    }
}
