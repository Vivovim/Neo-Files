import Foundation
import UniformTypeIdentifiers

struct FileSystemService {
    private let fileManager = FileManager.default

    func loadDirectory(at url: URL) throws -> DirectorySnapshot {
        let resourceKeys: Set<URLResourceKey> = [
            .contentTypeKey,
            .contentModificationDateKey,
            .fileSizeKey,
            .isDirectoryKey,
            .isPackageKey,
            .localizedNameKey
        ]

        let childURLs = try fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: Array(resourceKeys),
            options: [.skipsPackageDescendants]
        )

        let entries = childURLs.compactMap { childURL -> FileSystemEntry? in
            guard let resourceValues = try? childURL.resourceValues(forKeys: resourceKeys) else {
                return nil
            }

            let isDirectory = (resourceValues.isDirectory ?? false) && !(resourceValues.isPackage ?? false)
            let fileType = Self.fileTypeLabel(for: childURL, isDirectory: isDirectory)
            return FileSystemEntry(
                url: childURL,
                isDirectory: isDirectory,
                fileType: fileType,
                contentTypeIdentifier: resourceValues.contentType?.identifier,
                contentTypeDescription: resourceValues.contentType?.localizedDescription,
                fileSize: resourceValues.fileSize.map(Int64.init),
                contentModifiedDate: resourceValues.contentModificationDate
            )
        }
        .sorted { lhs, rhs in
            if lhs.isDirectory != rhs.isDirectory {
                return lhs.isDirectory && !rhs.isDirectory
            }

            return lhs.displayName.localizedStandardCompare(rhs.displayName) == .orderedAscending
        }

        return DirectorySnapshot(
            directoryURL: url,
            entries: entries,
            summary: makeSummary(for: entries)
        )
    }

    func moveItem(at sourceURL: URL, to destinationDirectoryURL: URL) throws {
        let destinationURL = uniqueDestinationURL(for: sourceURL, in: destinationDirectoryURL)
        try fileManager.moveItem(at: sourceURL, to: destinationURL)
    }

    func isDescendant(_ candidateURL: URL, of ancestorURL: URL) -> Bool {
        let candidateComponents = candidateURL.standardizedFileURL.pathComponents
        let ancestorComponents = ancestorURL.standardizedFileURL.pathComponents

        guard candidateComponents.count > ancestorComponents.count else {
            return false
        }

        return Array(candidateComponents.prefix(ancestorComponents.count)) == ancestorComponents
    }

    private func makeSummary(for entries: [FileSystemEntry]) -> DirectorySummary {
        let folderCount = entries.filter(\.isDirectory).count
        let groupedFiles = Dictionary(grouping: entries.filter { !$0.isDirectory }, by: \.fileType)

        let fileTypes = groupedFiles
            .map { FileTypeCount(type: $0.key, count: $0.value.count) }
            .sorted { lhs, rhs in
                if lhs.count != rhs.count {
                    return lhs.count > rhs.count
                }

                return lhs.type.localizedStandardCompare(rhs.type) == .orderedAscending
            }

        return DirectorySummary(folderCount: folderCount, fileTypes: fileTypes)
    }

    private func uniqueDestinationURL(for sourceURL: URL, in destinationDirectoryURL: URL) -> URL {
        var destinationURL = destinationDirectoryURL.appendingPathComponent(sourceURL.lastPathComponent)

        guard fileManager.fileExists(atPath: destinationURL.path) else {
            return destinationURL
        }

        let baseName = sourceURL.deletingPathExtension().lastPathComponent
        let pathExtension = sourceURL.pathExtension
        var counter = 2

        while fileManager.fileExists(atPath: destinationURL.path) {
            let candidateName = pathExtension.isEmpty
                ? "\(baseName) \(counter)"
                : "\(baseName) \(counter).\(pathExtension)"
            destinationURL = destinationDirectoryURL.appendingPathComponent(candidateName)
            counter += 1
        }

        return destinationURL
    }

    private static func fileTypeLabel(for url: URL, isDirectory: Bool) -> String {
        guard !isDirectory else {
            return "Folder"
        }

        let extensionText = url.pathExtension.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !extensionText.isEmpty else {
            return "No Ext"
        }

        return extensionText.uppercased()
    }
}
