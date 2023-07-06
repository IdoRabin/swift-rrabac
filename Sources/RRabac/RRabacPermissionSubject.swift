//
//  RRabacPermissionSubject.swift
//  
//
//  Created by Ido on 06/07/2023.
//

import Foundation
import MNUtils

public enum RRabacPermissionSubject : JSONSerializable, Hashable {
    case users([MNUID])
    case files([String])
    case routes([String])
    case webpages([String])
    case models([String])
    case commands([String])
    case underermined
}
