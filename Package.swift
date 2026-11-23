// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Portfolio",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0")
    ],
    targets: [
        .executableTarget(
            name: "Portfolio",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ]
        )
    ]
)
