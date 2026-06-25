import Foundation
import UniformTypeIdentifiers

struct FileSystemEntry: Identifiable, Hashable {
    let url: URL
    let isDirectory: Bool
    let fileType: String
    let contentTypeIdentifier: String?
    let contentTypeDescription: String?
    let fileSize: Int64?
    let contentModifiedDate: Date?

    var id: URL { url }

    private var normalizedPathExtension: String {
        url.pathExtension.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    var contentType: UTType? {
        guard let contentTypeIdentifier else {
            return nil
        }

        return UTType(contentTypeIdentifier)
    }

    var isAudioFile: Bool {
        contentType?.conforms(to: .audio) == true
    }

    var isVideoFile: Bool {
        contentType?.conforms(to: .movie) == true || contentType?.conforms(to: .video) == true
    }

    var isPagesDocument: Bool {
        normalizedPathExtension == "pages" || contentTypeIdentifier == "com.apple.iwork.pages.pages"
    }

    var isNumbersDocument: Bool {
        normalizedPathExtension == "numbers" || contentTypeIdentifier == "com.apple.iwork.numbers.numbers"
    }

    var isIWorkDocument: Bool {
        isPagesDocument || isNumbersDocument
    }

    var displayName: String {
        let lastPathComponent = url.lastPathComponent
        return lastPathComponent.isEmpty ? url.path : lastPathComponent
    }

    var detailLabel: String {
        if isDirectory {
            return "Folder"
        }

        if isPagesDocument {
            return "Pages"
        }

        if isNumbersDocument {
            return "Numbers"
        }

        return fileType
    }

    var inspectorKindLabel: String {
        if isDirectory {
            return "Folder"
        }

        if isPagesDocument {
            return "Pages Document"
        }

        if isNumbersDocument {
            return "Numbers Spreadsheet"
        }

        return contentTypeDescription ?? fileType
    }

    var symbolName: String {
        guard !isDirectory else {
            return "folder.fill"
        }

        if let contentType {
            if contentType.conforms(to: .image) {
                return "photo.fill"
            }

            if contentType.conforms(to: .audio) {
                return "waveform"
            }

            if contentType.conforms(to: .movie) || contentType.conforms(to: .video) {
                return "film.fill"
            }

            if contentType.conforms(to: .text) {
                return "doc.text.fill"
            }
        }

        if isPagesDocument {
            return "doc.text.fill"
        }

        if isNumbersDocument {
            return "tablecells.fill"
        }

        return "doc.fill"
    }
}
