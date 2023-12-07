// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RRabac",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "RRabac",
            targets: ["RRabac"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.76.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
        
        /// In-House pakcages
        // .package(url: "https://gitlab.com/ido_r_demos/dslogger.git", from: "0.0.1"),
        // .package(url: "https://gitlab.com/ido_r_demos/mnutils.git", from: "0.0.2"),
        .package(path:"../MNVaporUtils/")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "RRabac",
            dependencies: [
                // In-House pakcages
                // .product(name: "DSLogger", package: "DSLogger"),
                // .product(name: "MNUtils", package: "MNUtils"),
                .product(name: "MNVaporUtils", package: "MNVaporUtils"),
                
                .product(name: "Fluent", package: "fluent"),
                .product(name: "Vapor", package: "vapor"),
            ],
            swiftSettings: [
                .define("VAPOR"), // Vapor framework, to distinguish in classes that are also used in iOS / macOS.
                .define("NIO"),
            ]
        ),
        .testTarget(
            name: "RRabacTests",
            dependencies: ["RRabac"]),
    ]
)
