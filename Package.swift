// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RRabac",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "RRabac",
            targets: ["RRabac"]),
    ],
    dependencies: [
        // In-House pakcages
       .package(path: "../../xcode/DSLogger"),
       .package(path: "../../xcode/MNUtils/MNUtils"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "RRabac",
            dependencies: [
                // In-House pakcages
                .product(name: "DSLogger", package: "DSLogger"),
                .product(name: "MNUtils", package: "MNUtils")
            ]
        ),
        .testTarget(
            name: "RRabacTests",
            dependencies: ["RRABAC"]),
    ]
)
