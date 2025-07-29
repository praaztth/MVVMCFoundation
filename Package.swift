// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MVVMCFoundation",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MVVMCFoundation",
            targets: ["MVVMCFoundation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Vladimir089/SwiftHelper.git", .upToNextMajor(from: "0.1.2")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.7.1")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.0.0")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.0")),
        .package(url: "https://github.com/realm/realm-swift.git", .upToNextMajor(from: "20.0.2")),
        .package(url: "https://github.com/praaztth/PixVerseAPI.git", .upToNextMajor(from: "1.0.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MVVMCFoundation",
            dependencies: [
                .product(name: "SwiftHelper", package: "SwiftHelper"),
                .product(name: "SnapKit", package: "SnapKit"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "PixVerseAPI", package: "PixVerseAPI")
            ]),
    ]
)
