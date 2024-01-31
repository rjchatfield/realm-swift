// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "RealmMacro",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "RealmMacro",
            targets: ["RealmMacro"]
        ),
        .executable(
            name: "RealmMacroClient",
            targets: ["RealmMacroClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.1.1"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.15.2"),
    ],
    targets: [
        .macro(
            name: "RealmMacroMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(name: "RealmMacro", dependencies: ["RealmMacroMacros"]),
        .executableTarget(name: "RealmMacroClient", dependencies: ["RealmMacro"]),
        .testTarget(
            name: "RealmMacroTests",
            dependencies: [
                "RealmMacroMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ]
)