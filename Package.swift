// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ClipKit",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "ClipKit",
            path: "ClipKit",
            exclude: [
                "ClipKit.entitlements",
                "ClipKit.xcdatamodeld",
                "Persistence.swift"  // Excludes CoreData boilerplate (uses JSON persistence instead)
            ],
            resources: [
                .process("Assets.xcassets"),
                .process("Preview Content")
            ]
        ),
        .testTarget(
            name: "ClipKitTests",
            dependencies: ["ClipKit"],
            path: "ClipKitTests"
        )
    ]
)
