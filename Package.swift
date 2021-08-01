// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "RecoilSwift",
    
    platforms: [
        .iOS(.v10),
        .macOS("99")
    ],
    
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "RecoilSwift",
            targets: ["RecoilSwift"]),
    ],
    
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "4.0.0")), // dev
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.2.0")), // dev
    ],
    
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "RecoilSwift",
            dependencies: [],
            path: "Sources"),
        
        .testTarget(
            name: "RecoilSwiftTests",
            dependencies: [
                "RecoilSwift",
                "Quick",
                "Nimble"
            ],
            path: "Tests"),
    ],
    
    swiftLanguageVersions: [
        .v5
    ]
)
