import Foundation

struct FileSystemEntry: Identifiable, Hashable {
    let url: URL
    let isDirectory: Bool
    let fileType: String

    var id: URL { url }

    var displayName: String {
        let lastPathComponent = url.lastPathComponent
        return lastPathComponent.isEmpty ? url.path : lastPathComponent
    }

    var detailLabel: String {
        isDirectory ? "Folder" : fileType
    }

    var symbolName: String {
        isDirectory ? "folder.fill" : "doc.fill"
    }
}
