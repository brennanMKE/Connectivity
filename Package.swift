// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConnectivityKit",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_14),
        .tvOS(.v12),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "ConnectivityKit",
            targets: ["ConnectivityKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ConnectivityKit",
            dependencies: ["Reachability"],
            path: "Sources/ConnectivityKit"),
        .target(
            name: "Reachability",
            dependencies: [],
            path: "Sources/Reachability",
            publicHeadersPath: ""
        ),
        .testTarget(
            name: "ConnectivityKitTests",
            dependencies: ["ConnectivityKit"]),
    ]
)
