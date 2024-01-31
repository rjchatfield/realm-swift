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
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.2.2"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.1.2"),
        .package(path: "../"), // local 'realm-swift'
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
        .executableTarget(
            name: "RealmMacroClient",
            dependencies: [
                "RealmMacro",
                .product(name: "RealmSwift", package: "realm-swift"),
            ]
        ),
        .testTarget(
            name: "RealmMacroTests",
            dependencies: [
                "RealmMacroMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
                .product(name: "CustomDump", package: "swift-custom-dump"),
                .product(name: "RealmSwift", package: "realm-swift"),
            ]
        ),
    ]
)
