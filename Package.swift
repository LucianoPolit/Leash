// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Leash",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "Leash",
            targets: ["Leash"]
        ),
        .library(
            name: "LeashInterceptors",
            targets: ["LeashInterceptors"]
        ),
        .library(
            name: "RxLeash",
            targets: ["RxLeash"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/Alamofire/Alamofire.git",
            .upToNextMajor(from: "5.0.0")
        ),
        .package(
            url: "https://github.com/ReactiveX/RxSwift.git",
            .upToNextMajor(from: "5.0.0")
        ),
        .package(
            url: "https://github.com/AliSoftware/OHHTTPStubs",
            .upToNextMajor(from: "9.0.0")
        )
    ],
    targets: [
        .target(
            name: "Leash",
            dependencies: [
                "Alamofire"
            ],
            path: "Source/Core"
        ),
        .target(
            name: "LeashInterceptors",
            dependencies: [
                "Leash"
            ],
            path: "Source/Interceptors"
        ),
        .target(
            name: "RxLeash",
            dependencies: [
                "Leash",
                "RxSwift"
            ],
            path: "Source/RxSwift"
        ),
        .testTarget(
            name: "LeashTests",
            dependencies: [
                "Leash",
                "LeashInterceptors",
                "RxLeash",
                "OHHTTPStubsSwift"
            ],
            path: "Tests"
        )
    ]
)
