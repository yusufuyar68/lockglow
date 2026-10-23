// swift-tools-version: 6.0
import PackageDescription

// Swift language mode 5 for every target on purpose (no strict-concurrency surprises).
// Libraries are explicitly static so the app and the widget extension each link their own
// copy; nothing has to be embedded as a framework.
let package = Package(
    name: "VocabKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        // is5-watch: the Apple Watch app and its complications (CoreModels, SharedState, Scheduler).
        .watchOS(.v10),
    ],
    products: [
        .library(name: "CoreModels", type: .static, targets: ["CoreModels"]),
        .library(name: "TextFold", type: .static, targets: ["TextFold"]),
        .library(name: "SharedState", type: .static, targets: ["SharedState"]),
        .library(name: "Scheduler", type: .static, targets: ["Scheduler"]),
        .library(name: "ContentStore", type: .static, targets: ["ContentStore"]),
        .library(name: "Learning", type: .static, targets: ["Learning"]),
        .library(name: "Pronunciation", type: .static, targets: ["Pronunciation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.0.0"),
    ],
    targets: [
        .target(name: "CoreModels"),
        .target(name: "TextFold"),
        .target(name: "SharedState", dependencies: ["CoreModels"]),
        .target(name: "Scheduler", dependencies: ["CoreModels", "SharedState"]),
        // Leitner scheduling, queue composition, the app-private progress file and "Cümle kur"
        // (TextFold: its tiles are checked by folded keys). App only.
        .target(name: "Learning", dependencies: ["CoreModels", "TextFold"]),
        // "Söyle" practice: compares what the speech recognizer heard with the card. Pure. App only.
        .target(name: "Pronunciation"),
        .target(
            name: "ContentStore",
            dependencies: [
                "CoreModels",
                "TextFold",
                .product(name: "GRDB", package: "GRDB.swift"),
            ]
        ),
        .testTarget(name: "CoreModelsTests", dependencies: ["CoreModels"]),
        .testTarget(name: "TextFoldTests", dependencies: ["TextFold"]),
        .testTarget(name: "SharedStateTests", dependencies: ["SharedState", "CoreModels"]),
        .testTarget(name: "SchedulerTests", dependencies: ["Scheduler", "SharedState", "CoreModels"]),
        .testTarget(name: "LearningTests", dependencies: ["Learning", "CoreModels"]),
        .testTarget(name: "PronunciationTests", dependencies: ["Pronunciation"]),
        .testTarget(
            name: "ContentStoreTests",
            dependencies: [
                "ContentStore",
                "CoreModels",
                "TextFold",
                .product(name: "GRDB", package: "GRDB.swift"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
