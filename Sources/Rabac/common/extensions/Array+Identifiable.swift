//
//  Array+Identifiable.swift
//  XPlan
//
//  Created by Ido on 06/11/2021.
//

import Foundation

fileprivate let dlog : DSLogger? = DLog.forClass("Array+id")

extension Array {

    func elementsAt(indexPaths:[IndexPath])->[IndexPath:Element] {
        guard indexPaths.count > 0 else {
            return [:]
        }
        
        if DLog.IS_LOGS_ENABLED && (count > 200 || indexPaths.count > 200) {
            dlog?.note("Array where Element : Identifiable called elementsAt(indexPaths:) - this search may be CPU intensive (not efficient) use with small arrays only")
        }
        
        var result : [IndexPath:Element] = [:]
        
        indexPaths.forEach { indexPath in
            if let idx = indexPath.first {
                if idx >= 0 && idx < count {
                    result[indexPath] = self[idx]
                }
            }
        }
        
        return result
    }
}

extension Sequence where Element : Identifiable {
    var ids : [Element.ID] {
        return self.map { element in
            return element.id
        }
    }
    
    var dictionaryByIds : [Element.ID:Element] {
        var result : [Element.ID:Element] = [:]
        for item in self {
            result[item.id] = item
        }
        // can also use groupBy or to dictionaryBy:
        return result
    }
    
    func indexPathsFor(ids idsToSearch:[Element.ID]?)->[IndexPath:Element] {
        guard let idsToSearch = idsToSearch?.uniqueElements(), idsToSearch.count > 0 else {
            return [:]
        }
        if DLog.IS_LOGS_ENABLED && (ids.count > 200 || idsToSearch.count > 200) {
            dlog?.note("Array where Element : Identifiable called indexPathsFor(ids:) - this search may be CPU intensive (not efficient) use with small arrays only")
        }
        
        var result : [IndexPath:Element] = [:]
        self.forEachIndex { index, element in
            if idsToSearch.contains(element.id) {
                result[IndexPath(index: index)] = element
            }
        }
        
        return result
    }
}

// NOTE: Requires IndexPathTuple to exist
//struct IndexPathTuple<Element:Any> {
//    let element : Element?
//    let indexpath : IndexPath?
//    var isEmpty : Bool { return element == nil && indexpath == nil }
//}

extension Array where Element : Identifiable {
    
    func indexPathsFor(elements:[Element]?)->[IndexPath:Element] {
        guard let elements = elements else {
            return [:]
        }
        
        let ids = elements.map { elem in
            return elem.id
        }
        return self.indexPathsFor(ids: ids)
    }
    
    func indexedAnyFor(ids:[Element.ID]?)->[IndexPathTuple<Element>] {
        return self.indexPathsFor(ids: ids).toIIndexPathTuples()
    }
    
    func indexedAnyFor(elements:[Element]?)->[IndexPathTuple<Element>] {
        return self.indexPathsFor(elements: elements).toIIndexPathTuples()
    }
}
