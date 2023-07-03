//
//  Version.swift
//  
//
//  Created by Ido on 05/06/2023.
//

import Foundation
import MNUtils

typealias Semver = MNSemver

// See: Utils/SemVer.swift
enum PreRelease: String {
    case none = ""
    case alpha = "alpha"
    case beta = "beta"
    case RC = "RC"
}

// https://semver.org/spec/v2.0.0.html
// Swift package PackageDescription also has a Sever2 Version struct defined, but we will be using:

// Hard coded app version:
let RRABAC_NAME_STR = Bundle.main.bundleName ?? "RRabac"

// String fields allow only alphanumerics and a hyphen (-)
let RRABAC_BUILD_NR: Int = 55
let RRABAC_BUILD_VERSION = Semver(
    major: 0,
    minor: 1,
    patch: 0,
    prerelease: "\(PreRelease.alpha.rawValue)",
    metadata: [String(format: "%04X", RRABAC_BUILD_NR)]
)
