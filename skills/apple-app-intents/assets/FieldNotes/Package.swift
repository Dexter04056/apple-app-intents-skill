// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FieldNotes",
    platforms: [.macOS(.v15), .iOS(.v18)],
    products: [.library(name: "FieldNotesCore", targets: ["FieldNotesCore"])],
    targets: [
        .target(name: "FieldNotesCore"),
        .testTarget(name: "FieldNotesCoreTests", dependencies: ["FieldNotesCore"])
    ]
)
