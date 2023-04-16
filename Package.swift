// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "RecoilSwift",
    
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
    ],
    
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "RecoilSwift",
            targets: ["RecoilSwift"]),

        .library(
            name: "RecoilSwiftTestKit",
            targets: ["RecoilSwiftTestKit"]
        )
    ],
    
    dependencies: [
      // Dependencies declare other packages that this package depends on.
      .package(
        url: "https://github.com/hollyoops/SwiftUI-Hooks",
        from: "0.0.4"
      )
    ],
    
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "RecoilSwift",
            dependencies: [
                .product(name: "Hooks", package: "SwiftUI-Hooks")
            ],
            path: "Sources",
            resources: [
                .copy("Resources/graph-web")
            ]
        ),
        .target(
            name: "RecoilSwiftTestKit",
            dependencies: [
                "RecoilSwift"
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "RecoilSwiftTests",
            dependencies: [
                "RecoilSwift",
                "RecoilSwiftTestKit"
            ],
            path: "Tests"
        )
    ],
    
    swiftLanguageVersions: [
        .v5
    ]
)
