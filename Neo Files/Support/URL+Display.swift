import Foundation

extension URL {
    var neoDisplayName: String {
        let lastPathComponent = lastPathComponent
        return lastPathComponent.isEmpty ? path : lastPathComponent
    }

    var neoDisplayPath: String {
        let standardizedPath = standardizedFileURL.path
        let homePath = FileManager.default.homeDirectoryForCurrentUser.path

        guard standardizedPath.hasPrefix(homePath) else {
            return standardizedPath
        }

        return "~" + standardizedPath.dropFirst(homePath.count)
    }
}
