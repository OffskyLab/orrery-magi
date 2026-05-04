// swift-tools-version: 6.0
import PackageDescription

// TODO: Phase D switches this path dep to a URL dependency.
// Path dep is for local-only testing while orrery v2.6.0 is unreleased —
// it points at the sibling ../Orrery checkout where v2.6.0-ready code
// lives on feature/delegate-session.

let package = Package(
    name: "orrery-magi",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "orrery-magi", targets: ["orrery-magi"]),
        .library(name: "OrreryMagi", targets: ["OrreryMagi"]),
    ],
    dependencies: [
        .package(path: "../Orrery"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "orrery-magi",
            dependencies: [
                "OrreryMagi",
                .product(name: "OrreryCore", package: "orrery"),
            ],
            path: "Sources/orrery-magi"
        ),
        .target(
            name: "OrreryMagi",
            dependencies: [
                .product(name: "OrreryCore", package: "orrery"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/OrreryMagi"
        ),
        .testTarget(
            name: "OrreryMagiTests",
            dependencies: [
                "OrreryMagi",
                .product(name: "OrreryCore", package: "orrery"),
            ],
            path: "Tests/OrreryMagiTests"
        ),
    ]
)
