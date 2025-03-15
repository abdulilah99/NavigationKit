// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NavigationKit",
    platforms: [
        .macOS(.v14), .iOS(.v17), .tvOS(.v17), .visionOS(.v1)
    ],
    products: [
        .library(name: "NavigationKit", targets: ["NavigationKit"]),
    ],
    targets: [
        .target(name: "NavigationKit"),
        .testTarget(name: "NavigationKitTests", dependencies: ["NavigationKit"]),
    ]
)
