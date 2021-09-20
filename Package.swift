// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SexpyJSON",
    products: [
        .executable(
            name: "sxpj",
            targets: ["sxpj"]
        ),
        .library(
            name: "SexpyJSON",
            targets: ["SexpyJSON"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "1.0.1")),
    ],
    targets: [
        .executableTarget(
            name: "sxpj",
            dependencies: [
                "SexpyJSON",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "SexpyJSON",
            dependencies: []
        ),
        .testTarget(
            name: "SexpyJSONTests",
            dependencies: ["SexpyJSON"]
        ),
    ]
)
