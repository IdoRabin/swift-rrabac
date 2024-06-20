//
//  RRabacPermissionSubject.swift
//  
//
// Created by Ido Rabin for Bricks on 17/1/2024.

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
