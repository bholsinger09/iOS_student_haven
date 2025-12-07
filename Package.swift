// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "IOS_Student_Haven",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "IOS_Student_Haven",
            targets: ["IOS_Student_Haven"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "IOS_Student_Haven",
            path: "IOS_Studeent_Haven",
            sources: [
                "Models/AvatarModels.swift",
                "ViewModels/AvatarViewModel.swift"
            ]
        ),
        .testTarget(
            name: "IOS_Student_HavenTests",
            dependencies: ["IOS_Student_Haven"],
            path: "IOS_Student_HavenTests"
        )
    ]
)
