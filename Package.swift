// swift-tools-version: 6.0
import PackageDescription

// orrery v2.7.0-ready code lives on the `feature/magi` branch at
// OffskyLab/Orrery; we pin the exact commit so CI builds are
// reproducible. v1.1.1 will switch this to `.upToNextMajor(from: "2.7.0")`
// once orrery v2.7.0 is tagged and released.

let package = Package(
    name: "orrery-magi",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "orrery-magi", targets: ["orrery-magi"]),
        .library(name: "OrreryMagi", targets: ["OrreryMagi"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/OffskyLab/Orrery",
            revision: "ae868e2630a860ad094670fb9be8c04a7038eb14"
        ),
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
