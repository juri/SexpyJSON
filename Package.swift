// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SexpyJSON",
    products: [
        .executable(
            name: "DocBuilder",
            targets: ["DocBuilder"]
        ),
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
        .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .revision("swift-5.5-DEVELOPMENT-SNAPSHOT-2021-09-13-a")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "1.0.1")),
    ],
    targets: [
        .executableTarget(
            name: "DocBuilder",
            dependencies: [
                "FunctionDocExtractorCore",
            ]
        ),
        .executableTarget(
            name: "sxpj",
            dependencies: [
                "SexpyJSON",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "FunctionDocExtractorCore",
            dependencies: [
                "SwiftSyntax",
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
        .testTarget(
            name: "FunctionDocTests",
            dependencies: [
                "FunctionDocExtractorCore",
                "SexpyJSON",
                "SwiftSyntax",
            ]
        ),
    ]
)
