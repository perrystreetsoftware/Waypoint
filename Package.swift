// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Waypoint",
    platforms: [
        .iOS("18.0"),
    ],
    products: [
        .library(
            name: "Waypoint",
            targets: ["Waypoint"]),
    ],
    targets: [
        .target(
            name: "Waypoint"),
    ]
)
