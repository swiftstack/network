// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Network",
    products: [
        .library(
            name: "Async",
            targets: ["Async"]),
        .library(
            name: "Network",
            targets: ["Network"]),
    ],
    dependencies: [
        .package(name: "Platform"),
        .package(name: "Time"),
        .package(name: "Log"),
        .package(name: "Stream"),
        .package(name: "Test"),
        .package(name: "FileSystem"),
        .package(name: "Fiber"),
    ],
    targets: [
        .target(
            name: "Async",
            dependencies: ["Platform", "Fiber", "Time"],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-enable-experimental-concurrency"])
            ]),
        .target(
            name: "Network",
            dependencies: ["Platform", "Time", "Async", "Stream", "Log"],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-enable-experimental-concurrency"])
            ]),
        .testTarget(
            name: "NetworkTests",
            dependencies: ["Test", "Network", "FileSystem", "Fiber"],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-enable-experimental-concurrency"])
            ])
    ]
)

// MARK: - custom package source

#if canImport(ObjectiveC)
import Darwin.C
#else
import Glibc
#endif

extension Package.Dependency {
    enum Source: String {
        case local, remote, github

        static var `default`: Self { .local }

        var baseUrl: String {
            switch self {
            case .local: return "../"
            case .remote: return "https://swiftstack.io/"
            case .github: return "https://github.com/swift-stack/"
            }
        }

        func url(for name: String) -> String {
            return self == .local
                ? baseUrl + name.lowercased()
                : baseUrl + name.lowercased() + ".git"
        }
    }

    static func package(name: String) -> Package.Dependency {
        guard let pointer = getenv("SWIFTSTACK") else {
            return .package(name: name, source: .default)
        }
        guard let source = Source(rawValue: String(cString: pointer)) else {
            fatalError("Invalid source. Use local, remote or github")
        }
        return .package(name: name, source: source)
    }

    static func package(name: String, source: Source) -> Package.Dependency {
        return source == .local
            ? .package(name: name, path: source.url(for: name))
            : .package(name: name, url: source.url(for: name), .branch("dev"))
    }
}
