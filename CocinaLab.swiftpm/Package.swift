// swift-tools-version: 5.9

import AppleProductTypes
import PackageDescription

let package = Package(
    name: "CocinaLab",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "CocinaLab",
            targets: ["CocinaLab"],
            bundleIdentifier: "dev.fernandoparra.CocinaLab",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .openBook),
            accentColor: .presetColor(.brown),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "CocinaLab",
            path: "."
        )
    ]
)
