//
//  Persist.swift
//  
//
//  Created by Ido on 01/03/2023.
//

import Foundation

// Probably redefined in other places?? private typealias AnyCodable = Any & Codable

/// Any mechanism that may persist key-value items
protocol Persister {
    var isNeedsSave : Bool { get set }
    var isLoaded : Bool { get }
    var autosaveTimeout : TimeInterval { get set }
    func noteChange(_ change:String, newValue:AnyCodable)
    func blockChanges(block:(_ persister : Persister)->Void)
    func resetToDefaults() throws
    func saveIfNeeded() throws ->Bool
    func save() throws
    func getExternalPropValue(named:String)->AnyCodable?
    func setExternalPropValue(named:String, value:AnyCodable) throws ->Bool
}

fileprivate var _persister : Persister? = nil

// MARK: Persist protocol - will persist randome properties in random locations in code in one cental "settings" manager
@propertyWrapper
struct Persist<T:Equatable & Codable> : Codable {
    var persister : Persister? {
        return _persister
    }
    
    enum CodingKeys : String, CodingKey {
        case name  = "name"
        case value = "value"
    }
    
    // MARK: properties
    private var _value : T
    @SkipEncode var name : String = ""
    
    var wrappedValue : T {
        get {
            return _value
        }
        set {
            let oldValue = _value
            let newValue = newValue
            if newValue != oldValue {
                _value = newValue
                let changedKey = name.count > 0 ? "\(self.name)" : "\(self)"
                self.persister?.noteChange(changedKey, newValue: newValue)
            }
        }
    }

    init(name newName:String, `default` defaultValue : T) {
        
        // basic setup:
        self.name = newName
        
        // Adv. setup:
        if _persister?.isLoaded == true {
            // dlog?.info("searching for [\(newName)] in \(AppSettings.shared.other.keysArray.descriptionsJoined)")
            if let loadedVal = _persister?.getExternalPropValue(named: newName) as? T {
                self._value = loadedVal
                // dlog?.success("found and set for [\(newName)] in \(AppSettings.shared.other.keysArray.descriptionsJoined)")
            } else {
                //if Debug.IS_DEBUG && AppSettings.shared.other[newName] != nil {
                //    dlog?.warning("failed cast \(AppSettings.shared.other[newName].descOrNil) as \(T.self)")
                //}
                
                self._value = defaultValue
            }
        } else {
            self._value = defaultValue
        }
    }
    
    // MARK: AppSettable: Decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode only whats needed
        self.name = try container.decode(String.self, forKey: .name)
        self._value = try container.decode(T.self, forKey: .value)
    }
    
    // MARK: AppSettable: Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name,   forKey: .name)
        try container.encode(_value, forKey: .value)
    }
}
