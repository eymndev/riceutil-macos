// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Riceutil",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "Riceutil",
            path: "Sources/Riceutil"
        ),
    ]
)
