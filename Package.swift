// swift-tools-version: 6.0
import PackageDescription

// NOTE on target name `OrreryMagiStandalone`:
// The Orrery package (../Orrery) currently also declares a target named
// `OrreryMagi` during the Phase 2 split gating period. SPM forbids two
// packages in the same graph from having targets with identical names,
// so we use `OrreryMagiStandalone` as the internal target name while
// keeping the external library product name as `OrreryMagi`. After
// Step 4 cleanup removes Orrery's target, the internal rename can be
// reverted (the product name — what consumers see — never changes).

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
