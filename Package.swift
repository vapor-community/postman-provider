// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Postman",
    products: [
        .library(name: "Postman", targets: ["Postman"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "Postman", dependencies: ["Vapor"]),
        .testTarget(name: "PostmanTests", dependencies: ["Vapor", "Postman"]),
    ]
)
