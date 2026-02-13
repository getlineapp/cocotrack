// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "cocotrack",
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
            name: "cocotrack"
        )
    ]
)
