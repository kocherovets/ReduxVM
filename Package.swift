// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReduxVM",
    platforms: [.iOS(.v11), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ReduxVM",
            targets: ["ReduxVM"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/kocherovets/DeclarativeTVC", from: "1.0.22"),
        .package(url: "https://github.com/kocherovets/RedSwift", from: "2.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ReduxVM",
            dependencies: ["DeclarativeTVC", "RedSwift"]),
        .testTarget(
            name: "ReduxVMTests",
            dependencies: ["ReduxVM"]),
    ]
)
