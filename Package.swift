// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "cocotrack",
    defaultLocalization: "pl",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "cocotrack",
            targets: ["cocotrack"]
        )
    ],
    targets: [
        .executableTarget(
            name: "cocotrack",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "cocotrackTests",
            dependencies: ["cocotrack"]
        )
    ]
)
