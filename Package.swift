import PackageDescription

let package = Package(
    name: "Leash",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "4.5.0")
    ]
)
