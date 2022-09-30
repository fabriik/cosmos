// swift-tools-version:5.3
//
import PackageDescription

let package = Package(
    name: "Cosmos",
    platforms: [
        .iOS(.v11),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "Cosmos",
            targets: ["Cosmos"])
    ],
    targets: [
        .binaryTarget(
            name: "Cosmos",
            path: "cosmos-bundled/build-frameworks/Cosmos.xcframework"
        )
    ]
)
