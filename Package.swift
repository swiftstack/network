// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Network",
    products: [
        .library(name: "Network", targets: ["Network"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-stack/platform.git",
            from: "0.4.0"),
        .package(
            url: "https://github.com/swift-stack/async.git",
            from: "0.4.0"),
        .package(
            url: "https://github.com/swift-stack/stream.git",
            from: "0.4.0"),
        .package(
            url: "https://github.com/swift-stack/test.git",
            from: "0.4.0")
    ],
    targets: [
        .target(name: "Network", dependencies: ["Platform", "Async", "Stream"]),
        .testTarget(
            name: "NetworkTests",
            dependencies: ["Network", "AsyncDispatch", "Test"])
    ]
)
