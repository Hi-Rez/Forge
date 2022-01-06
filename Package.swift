// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Forge",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13)],
    products: [
        .library(
            name: "Forge",
            targets: ["Forge"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(name: "Forge")
    ],
    swiftLanguageVersions: [.v5]
)
