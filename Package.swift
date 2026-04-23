// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "orrery-magi",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "orrery-magi", targets: ["orrery-magi"]),
        .library(name: "OrreryMagi", targets: ["OrreryMagiStandalone"]),
    ],
    dependencies: [
        .package(path: "../Orrery"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "orrery-magi",
            dependencies: [
                "OrreryMagiStandalone",
                .product(name: "OrreryCore", package: "orrery"),
            ],
            path: "Sources/orrery-magi"
        ),
        .target(
            name: "OrreryMagiStandalone",
            dependencies: [
                .product(name: "OrreryCore", package: "orrery"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/OrreryMagi"
        ),
    ]
)
