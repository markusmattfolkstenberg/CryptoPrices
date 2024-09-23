// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CryptoPriceModules",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Models", targets: ["Models"]),
        .library(name: "Services", targets: ["Services"]),
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "CryptocurrencyDetailsFeature", targets: ["CryptocurrencyDetailsFeature"]),
        .library(name: "CryptocurrencyListFeature", targets: ["CryptocurrencyListFeature"]),
        .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
        .library(name: "Common", targets: ["Common"]),
    ],
    targets: [
        .target(
            name: "Models"
        ),
        .testTarget(name: "ModelsTests",
                    dependencies: ["Models"]),
        .target(
            name: "Services",
            dependencies: [
                "Models"
            ]
        ),
        .testTarget(
            name: "ServicesTests",
                    dependencies: ["Services"]
        ),
        .target(
            name: "AppFeature",
            dependencies: [
                "CryptocurrencyListFeature",
                "CryptocurrencyDetailsFeature",
                "SettingsFeature",
                "Common"
            ]
        ),
        .target(
            name: "CryptocurrencyListFeature",
            dependencies: [
                "Services",
                "Models",
                "Common",
                "CryptocurrencyDetailsFeature"
            ]
        ),
        .testTarget(
            name: "CryptocurrencyListFeatureTests",
            dependencies: [
                "Services",
                "Models",
                "Common",
                "CryptocurrencyDetailsFeature",
                "CryptocurrencyListFeature",
                "Mocks"
            ]),
        .target(
            name: "CryptocurrencyDetailsFeature",
            dependencies: [
                "Services",
                "Models",
                "Common"
            ]
        ),
        .target(
            name: "SettingsFeature",
            dependencies: [
                "Models",
                "Common",
                "Services"
            ]
        ),
        .target(
            name: "Common",
            dependencies: []
        ),
        .target(
            name: "Mocks",
            dependencies: [
                "Services",
                "Models",
                "Common"
            ])
    ]
)
