//
//  DictionaryEx.swift
//  zync
//
//  Created by Ido on 10/11/2021.
//  Copyright © 2022 idorabin. All rights reserved.
//

import Foundation

extension Dictionary {
    
    func hasKey(_ key : Key)->Bool {
        return self[key] != nil
    }
    /// Merge a dictionary into the existing dictionay. Will always override existing keys with the new values in case there are duplicates.
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
    
    /// returns a merged dictionary - the result of merging the existing dictionay with another. Will always override existing keys with the new values in case there are duplicates.
    func merging(dict: [Key: Value])->[Key:Value] {
        var result :[Key:Value] = [:]
        for (k, v) in self {
            result.updateValue(v, forKey: k)
        }
        for (k, v) in dict {
            result.updateValue(v, forKey: k)
        }
        return result
    }
    
    /// Replace a given key in the dictionary to a new key, while setting the keys' original value as the new keys value
    /// If the key does not exist in the dictionay, no change will occur
    ///
    /// - Parameters:
    ///   - fromKey: key to be replaced
    ///   - toKey: new key fro the same value
    mutating func replaceKey(fromKey: Dictionary.Key, toKey: Dictionary.Key) {
        if let entry = self.removeValue(forKey: fromKey) {
            self[toKey] = entry
        }
    }
    
    
    /// Replace a given set of keys in the dictionary to new keys, while setting the keys' original values as the new keys values
    /// If any of the pair's original kays does not exist in the dictionay, that pair will be ignored, and the rest or the replacements will take place
    ///
    /// - Parameters:
    ///   - pairs: keys to be replaced with corresponding new keys
    mutating func replaceKeys(pairs: [(from:Dictionary.Key, to:Dictionary.Key)]) {
        for pair in pairs {
            self.replaceKey(fromKey: pair.from, toKey: pair.to)
        }
    }
    
    // Will remove all objects excpet
    
    /// Remove all items except the given keys and their values
    ///
    /// - Parameter but: keys to keep, along with their values
    mutating func removeAll(but keysToKeep: [Dictionary.Key]) {
        
        // get a subset dictionary of all items with the given keys
        let sub = self.filter { (tuple) -> Bool in
            return keysToKeep.contains(tuple.key)
        }
        // Clear
        self.removeAll()
        
        // Return the subset we wanted to keep to self
        self.merge(dict: sub)
    }
    
    @discardableResult
    mutating func remove(valuesForKeys keysToRemove: [Dictionary.Key])->[Dictionary.Key:Dictionary.Value] {
        var result : [Dictionary.Key:Dictionary.Value] = [:]
        
        for key in keysToRemove {
            if let val = self.removeValue(forKey: key) {
                result[key] = val
            }
        }
        
        return result
    }
    
    func removing(valuesForKeys keysToRemove: [Dictionary.Key])->[Dictionary.Key:Dictionary.Value] {
        var result : [Dictionary.Key:Dictionary.Value] = self // copy
        result.remove(valuesForKeys: keysToRemove)
        return result
    }
    
    var valuesArray : [Value] {
        return Array(self.values)
    }
    
    var keysArray : [Key] {
        return Array(self.keys)
    }
}

extension Dictionary where Value : Equatable {
    
    /// Returns a dictionary with all Keys and Values that are equal (Equatable) between both dictionaries. That is, for the same key, the same value exists in both dictionaries.
    /// - Parameter other: other dictionary to intersect
    func intersection(other : [Key: Value])->[Key: Value] {
        var result : [Key: Value] = [:]
        for (key, val) in self {
            if other[key] == val {
                result[key] = val
            }
        }
        return result
    }
    
    ///
    /// Note - CPU not very efficient!
    
    
    /// Returns all keys that map a value equal (uses Equatable) to the given value:
    /// - Parameters:
    ///   - valueToFind: value to find keys for
    ///   - stopOnFirst: stops searching after the first value found
    /// - Returns: an array of all the keys that map to given value.
    func findKeysByValue(_ valueToFind: Value, stopOnFirst:Bool = false)->[Key] {
        var result : [Key] = []
        for (key, val) in self {
            if valueToFind == val {
                result.append(key)
                if stopOnFirst {
                    break
                }
            }
        }
        return result
    }
}

extension Dictionary where Key : Comparable {
    var sortedKeys : [Key] {
        return Array(self.keys.sorted()) // Do not: .reversed()
    }
    
    var valuesSortedByKeys : [Value] {
        var result : [Value] = []
        for sortedKey in self.sortedKeys {
            if let sortedValue = self[sortedKey] {
                result.append(sortedValue)
            }
        }
        return result
    }
}

extension Dictionary where Value : Comparable & Hashable {
    
    var keysForLargestValue : [Key] {
        var mostKeys = Set<Key>()

        let mostVal = self.values.sorted().last // ascending (first is smallest)
        if let mostVal = mostVal {
            for (key, val) in self{
                if val == mostVal {
                    mostKeys.update(with: key)
                }
            }
        }
        
        return mostKeys.allElements()
    }
    
    var keysForSmallestValue : [Key] {
        var leastKeys = Set<Key>()
        let leastVal = self.values.sorted().first // ascending (first is smallest)
        if let leastVal = leastVal {
            for (key, val) in self{
                if val == leastVal {
                    leastKeys.update(with: key)
                }
            }
        }
        
        return leastKeys.allElements()
    }
    
    var sortedValues : [Value] {
        return Array(self.values.sorted().reversed())
    }
    
    var tuplesSortedByValues : [(Key, Value)] {
        return self.sorted { (txt1, txt2) -> Bool in
            return txt1.value > txt2.value
        }
    }
    
    var keysSortedByValues : [Key] {
        return self.sorted { (txt1, txt2) -> Bool in
            return txt1.value > txt2.value
            }.map { (item) -> Key in
                item.key
        }
    }
    
    var keysSortedByLowestValues : [Key] {
        return self.sorted { (txt1, txt2) -> Bool in
            return txt1.value < txt2.value
            }.map { (item) -> Key in
                item.key
        }
    }
}

extension Dictionary where Key : FloatingPoint {
    
    /// Will normalize the dictionary keys so that the sum of all the keys will total 1.0 exactly.
    func normalizingKeys()->[Key:Value] {
        var result : [Key:Value] = [:]
        var sum : Key = 0
        for (key, _) in self {
            sum += abs(key)
        }
        
        let centimil = sum / 100000
        for (key, val) in self {
            var newKey = sum.isZero ? 0 : (key / sum)
            while result[newKey] != nil {
                newKey += Key(signOf: centimil, magnitudeOf: centimil)
            }
            result[newKey] = val
        }
        return result
    }
}

extension Dictionary where Value : FloatingPoint {
    /// Will normalize the dictionary values so that the sum of all the values will total 1.0 exactly.
    func normalizingValues()->[Key:Value] {
        var result : [Key:Value] = [:]
        var sum : Value = 0
        for (_, value) in self {
            sum += abs(value)
        }
        
        for (key, val) in self {
            result[key] = sum.isZero ? 0 : (val / sum)
        }
        return result
    }
}


extension Dictionary {

    mutating func add<T>(_ element: T, toArrayOn key: Key) where Value == [T] {
        self[key] == nil ? self[key] = [element] : self[key]?.append(element)
    }
}

extension Dictionary where Value : Sequence, Value.Element : Equatable {
    
    @discardableResult
    func isValues(for key:Key, contains value: Value.Element)->Bool {
        return self[key]?.contains(value) ?? false
    }
    
    
    @discardableResult
    /// Add element to the Value (which is an sequence of equatables) if the value is not already in the sequence (using == equatable comparison to check this)
    /// - Parameters:
    ///   - element: element to add to the sequence (if not already in the sequence!)
    ///   - key: key for the sequence to add the element to
    /// - Returns: true when element was added, false when element already existed in the sequence!
    mutating func addIfNeeded<T>(element: T, for key:Key)->Bool where Value == [T] {
        if self[key] == nil {
            self[key] = [element]
            return true
        } else if self[key]!.contains(element) == false {
            self[key]?.append(element)
            return true
        } else {
            // Already exists
            return false
        }
    }
    
    
    
    @discardableResult
    /// Will remove all elements equal to element from the sequence in the dictionary's given key
    /// - Parameter element to remove coppies / duplicates of from the sequence
    /// - Returns: key for the sequence to remove the element/s from
    mutating func remove<T>(_ element: T, for key:Key)->[T]? where Value == [T] {
        guard var sequence = self[key] else {
            return nil
        }
        
        let removed = self[key]?.filter({ elem in
            elem == element
        })
        
        let amtRemoved = sequence.remove(elementsEqualTo: element)
        if RabacDebug.IS_DEBUG && amtRemoved != removed?.count {
            preconditionFailure("Dictionary<K:any,V:[Equatable]> remove(_:forKey:) failed since amtRemoved \(amtRemoved) != \(removed?.count ?? 0) removed elems: \((removed ?? []).descriptionLines)")
        }
        
        self[key] = sequence // after mutation // TODO: check if can be done with in-place code such as self[key?].remove(bla) and still mutates correctly...
        
        return removed
    }
}


extension Dictionary where Value == Array<Any> {
    func count(for key:Key)->Int {
        return self[key]?.count ?? 0
    }
}

