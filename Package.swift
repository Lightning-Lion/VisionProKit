// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "VisionProKit",
    platforms: [
        .visionOS(.v26),
        .macOS(.v26),
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "VisionProKit",
            targets: ["VisionProKit"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "VisionProKit",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility")
            ]),
    ]
)
