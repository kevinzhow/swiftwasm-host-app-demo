// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swiftwasm-host-app-demo",
    platforms: [
        .macOS(.v10_15), .iOS(.v13)
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/shareup/wasm-interpreter-apple.git", from: "0.6.1"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.6.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "swiftwasm-host-app-demo",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "WasmInterpreter", package: "wasm-interpreter-apple")
            ],
            resources: [
                .copy("Resource/swiftwasm.wasm")
            ]),
        .testTarget(
            name: "swiftwasm-host-app-demoTests",
            dependencies: ["swiftwasm-host-app-demo"]),
    ]
)
