//
//  BUID.swift
//  bricks
//
//  Created by Ido on 02/12/2021.
//

import Foundation

fileprivate let dlog : DSLogger? = DLog.forClass("TUID")

enum BUIDType : String {
    case doc            = "DOC"
    case docsettings    = "DSET"
    case docstats       = "DSTT"
    case docinfo        = "DINF"
    case doclayers      = "DLRS"
    
    case layer          = "LYR"
    case user           = "USR"
    case usersettings   = "USET"
    case role           = "ROL"
    
    case person         = "PER"
    case company        = "COM"
    
    static var all : [BUIDType] = []
}

protocol BUIDProtocol : Hashable {
    var uid : UUIDv5 { get }
    var type : String { get }
}

extension BUIDProtocol {
    
    // MARK: Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(uid)
    }
}

// BUID/ TUID is a wrapper for UUID(version 5) and type string, wrapping a v4 UUID as the namespace
// Using UUID v5 we can also embed the checksum of the type and namespace if we are the ones creating the UUID.
// Using UUID v5 we can also validate the checksum of the type and namespace if we recieved the UUID as a string from remote sources.
// reference:  https://www.rfc-editor.org/rfc/rfc4122

class BUID : BUIDProtocol, LosslessStringConvertible, Comparable, Codable {
    
    // Seperator
    static let SEPARATOR : String = "|"
    static let NO_TYPE : String = "?"
    static let REGEX : String = "^[0-9a-zA-Z]{2,6}\\|[0-9a-fA-F]{8}\\b-[0-9a-fA-F]{4}\\b-[0-9a-fA-F]{4}\\b-[0-9a-fA-F]{4}\\b-[0-9a-fA-F]{12}$"
    // Native iOS UUID is a RFC 4122 version 5 UUID:.
    private var _uid : UUIDv5
    var uid : UUIDv5 {
        return _uid
    }
    
    var type : String {
        dlog?.warning("\(Swift.type(of: self)) subclass of BUID must override .type getter!")
        return Self.NO_TYPE
    }
    
    func setType(str:String? = BUID.NO_TYPE) {
        // Does nothing
        // Future subclasses might override setType and store the value
        if RabacDebug.IS_DEBUG {
            dlog?.warning("\(Swift.type(of: self)) subclass of BUID must override .setType()")
        }
    }
    
    func setType(type:BUIDType) {
        self.setType(str: type.rawValue)
    }
    
    public var uuidString: String {
        return "\(type)\(Self.SEPARATOR)\(uid.uuidString)"
    }
    
    // MARK: Equatable
    public static func == (lhs: BUID, rhs: BUID) -> Bool {
        return lhs.type == rhs.type && lhs.uid == rhs.uid
    }
    
    // MARK: Comperable
    // for sorting UIDs by type, then by UUID hash value
    public static func < (lhs: BUID, rhs: BUID) -> Bool {
        return lhs.type < rhs.type && lhs.uid.hashValue == rhs.uid.hashValue
    }
    
    // MARK: LosslessStringConvertible
    required convenience init?(_ description: String) {
        let components = description.components(separatedBy: Self.SEPARATOR)
        guard description.count > 12 && components.count < 2 else {
            // Bad string size or comps
            dlog?.warning("\(Self.self).init (LosslessStringConvertible) failed with too few components!")
            return nil
        }

        // This has some kind of redundency that even if no type, we still get the uuid
        var type = Self.NO_TYPE
        if components.count > 1 {
            type = Array(components.prefix(components.count - 1)).joined();
        }
        
        if type.count > 0,
            let uidString = components.last
        {
            do {
                let uid = try UUID(version: .v5, name: type, nameSpace: .custom(uidString))
                // Call init
                self.init(uid:uid, typeStr: type)
            } catch let error {
                dlog?.warning("\(Self.self).init (LosslessStringConvertible) [\(description)] did not contain a BUIDType or type string. \(error.description)")
                return nil
            }
            
            if RabacDebug.IS_DEBUG && type == Self.NO_TYPE {
                dlog?.warning("\(Self.self).init (LosslessStringConvertible) [\(description)] did not contain a BUIDType or type string.")
            }
        } else {
            dlog?.warning("\(Self.self).init (LosslessStringConvertible) failed: [\(description)] could not be used to init.")
            return nil
        }
    }
    
    // MARK: StringConvertible
    public var description: String {
        return uuidString
    }
    
    // MARK: Default initializers:
    required init(typeStr:String = BUID.NO_TYPE) {
        do {
            self._uid = try UUIDv5(version: .v5, name: typeStr, nameSpace: .uuidV4)
        } catch let error {
            dlog?.warning("TUID.init(type:String) failed: \(error.description)")
            self._uid = UUID();
        }
        self.setType(str:type)
    }

    required init(uid auid: UUID, typeStr atype:String = BUID.NO_TYPE) {
        switch auid.version {
        case .v5:
            // We re-use all components
            self._uid = auid
            self.setType(str: atype)
        case .v4:
            do {
                self._uid = try UUID(version: .v5, name: atype, nameSpace: .custom(auid.uuidString));
            } catch let error {
                dlog?.warning("TUID.init(uid:type) failed creating UUID: \(error.description)")
                self._uid = UUID();
            }
            self.setType(str: atype)
        default:
            self._uid = UUID(uuidString:UID_EMPTY_STRING)!;
        }
        
        if RabacDebug.IS_DEBUG && !self._uid.isValid(name: atype) {
            dlog?.warning("TUID.init(uid:type) auid hashed type does not match the provided type: \(atype)")
            return
        }
    }

    convenience init(type:BUIDType = .doc) {
        self.init(typeStr: type.rawValue)
    }

    convenience init(uidV5 auid: UUID, type:BUIDType) {
        self.init(uid:auid, typeStr:type.rawValue)
    }

    convenience init?(uuidString: String, typeStr:String? = nil) {
        guard let auid = UUID(uuidString: uuidString) else {
            dlog?.warning("failed using uuidString: \(uuidString) to create a UUID instance!")
            return nil
        }
        self.init(uid:auid, typeStr:typeStr ?? BUID.NO_TYPE)
    }

    convenience init?(uuidString: String, type buidType:BUIDType) {
        guard let auid = UUID(uuidString: uuidString) else {
            return nil
        }
        self.init(uid:auid, typeStr:buidType.rawValue)
    }
}

protocol BUIDable { // DO NOT: Identifiable  because it clashes with Fluent's Model protocol @ID
    
    var id : UUID? { get }
    var buid : BUID? { get }
}

// MARK: Sorting of BUID arrays
extension Array where Element : BUID {
    mutating func sort() {
        self.sort { buid1, buid2 in
            return buid1 < buid2
        }
    }
    
    func sorted()->[Element] {
        return self.sorted { buid1, buid2 in
            return buid1 < buid2
        }
    }
    
    func contains(buid:Element?)->Bool {
        guard let buid = buid else {
            return false
        }
        return self.contains(buid)
    }
    
    func firstIndex(ofBuid:Element?)->Int? {
        guard let buid = ofBuid else {
            return nil
        }
        return self.firstIndex(of: buid)
    }
    
    func lastIndex(ofBuid:Element?)->Int? {
        guard let buid = ofBuid else {
            return nil
        }
        return self.lastIndex(of: buid)
    }
}
