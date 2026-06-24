import Foundation

struct DirectorySnapshot: Identifiable, Equatable {
    let directoryURL: URL
    let entries: [FileSystemEntry]
    let summary: DirectorySummary

    var id: URL { directoryURL }

    var title: String {
        directoryURL.neoDisplayName
    }
}

struct DirectorySummary: Equatable {
    let folderCount: Int
    let fileTypes: [FileTypeCount]

    var totalFileCount: Int {
        fileTypes.reduce(0) { $0 + $1.count }
    }
}

struct FileTypeCount: Identifiable, Equatable {
    let type: String
    let count: Int

    var id: String { type }
}

struct StagedMove: Equatable {
    let entry: FileSystemEntry
    let sourceDirectoryURL: URL
}

struct AlertContext: Equatable {
    let title: String
    let message: String
}
