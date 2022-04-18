// swift-tools-version:5.6
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
        .package(url: "https://github.com/apple/swift-syntax.git", exact: "0.50600.1"), // name: SwiftSyntax
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "1.0.1")),
    ],
    targets: [
        .executableTarget(
            name: "DocBuilder",
            dependencies: [
                "FunctionDocExtractorCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
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
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxParser", package: "swift-syntax"),
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
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxParser", package: "swift-syntax"),
            ],
            resources: [
                .copy("F/Functions"),
            ]
        ),
    ]
)
