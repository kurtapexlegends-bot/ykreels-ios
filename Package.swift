// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YKReels",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "ReelCore", targets: ["ReelCore"]),
        .library(name: "ReelDatabase", targets: ["ReelDatabase"]),
        .library(name: "ReelEngine", targets: ["ReelEngine"]),
        .library(name: "ReelPlayer", targets: ["ReelPlayer"]),
        .library(name: "ReelDownload", targets: ["ReelDownload"]),
        .library(name: "ReelUI", targets: ["ReelUI"]),
        .library(name: "ReelApp", targets: ["ReelApp"])
    ],
    dependencies: [
        // High-performance SQLite engine with WAL mode and FTS5 support
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.29.0")
    ],
    targets: [
        // MARK: - Core Domain Models & Design System Tokens
        .target(
            name: "ReelCore",
            dependencies: [],
            path: "Sources/ReelCore"
        ),
        
        // MARK: - Persistence & SQLite Database
        .target(
            name: "ReelDatabase",
            dependencies: [
                "ReelCore",
                .product(name: "GRDB", package: "GRDB.swift")
            ],
            path: "Sources/ReelDatabase"
        ),
        
        // MARK: - Content Catalog & Stream Resolver Engine
        .target(
            name: "ReelEngine",
            dependencies: [
                "ReelCore",
                "ReelDatabase"
            ],
            path: "Sources/ReelEngine"
        ),
        
        // MARK: - AVPlayer Pool & Playback Gesture Engine
        .target(
            name: "ReelPlayer",
            dependencies: [
                "ReelCore"
            ],
            path: "Sources/ReelPlayer"
        ),
        
        // MARK: - Background Offline Downloads & Cache
        .target(
            name: "ReelDownload",
            dependencies: [
                "ReelCore",
                "ReelDatabase"
            ],
            path: "Sources/ReelDownload"
        ),
        
        // MARK: - SwiftUI User Interface & Navigation
        .target(
            name: "ReelUI",
            dependencies: [
                "ReelCore",
                "ReelDatabase",
                "ReelEngine",
                "ReelPlayer",
                "ReelDownload"
            ],
            path: "Sources/ReelUI"
        ),
        
        // MARK: - App Entrypoint & Lifecycle
        .target(
            name: "ReelApp",
            dependencies: [
                "ReelUI"
            ],
            path: "Sources/ReelApp"
        ),
        
        // MARK: - Automated Test Suite
        .testTarget(
            name: "ReelTests",
            dependencies: [
                "ReelCore",
                "ReelDatabase",
                "ReelEngine",
                "ReelPlayer",
                "ReelDownload"
            ],
            path: "Tests/ReelTests"
        )
    ]
)
