import AppKit
import Combine

@MainActor
final class FileBrowserStore: ObservableObject {
    private let fileSystemService = FileSystemService()
    private var expandedFolderPath: [URL] = []
    private var selectedURLsByColumn: [URL?] = []
    private var scopedRootURL: URL?
    private var isAccessingScopedResource = false

    @Published
    var rootURL: URL?
    @Published
    var columns: [DirectorySnapshot] = []
    @Published
    var stagedMove: StagedMove?
    @Published
    var alertContext: AlertContext?

    var rootPathText: String {
        rootURL?.neoDisplayPath ?? "Choose a folder to begin."
    }

    var previewEntry: FileSystemEntry? {
        for index in columns.indices.reversed() {
            if let entry = selectedEntry(in: index) {
                return entry
            }
        }

        return nil
    }

    var stagedMoveDescription: String {
        guard let stagedMove else {
            return "No move queued"
        }

        return "\(stagedMove.entry.displayName) -> choose a destination column"
    }

    func chooseRootFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Open"
        panel.message = "Choose a root folder for the Neo Files column browser."

        if panel.runModal() == .OK, let url = panel.url {
            do {
                try openRoot(url)
            } catch {
                presentError(
                    title: "Unable to Open Folder",
                    message: error.localizedDescription
                )
            }
        }
    }

    func openRoot(_ url: URL) throws {
        beginScopedAccess(to: url.standardizedFileURL)

        rootURL = url.standardizedFileURL
        expandedFolderPath = []
        selectedURLsByColumn = []
        stagedMove = nil

        do {
            try rebuildColumns()
        } catch {
            rootURL = nil
            endScopedAccess()
            throw error
        }
    }

    func refresh() {
        do {
            try rebuildColumns()
        } catch {
            presentError(title: "Refresh Failed", message: error.localizedDescription)
        }
    }

    func select(_ entry: FileSystemEntry, in columnIndex: Int) {
        selectedURLsByColumn = Array(selectedURLsByColumn.prefix(columnIndex))
        selectedURLsByColumn.append(entry.url)

        expandedFolderPath = Array(expandedFolderPath.prefix(columnIndex))
        if entry.isDirectory {
            expandedFolderPath.append(entry.url)
        }

        do {
            try rebuildColumns()
        } catch {
            presentError(title: "Folder Load Failed", message: error.localizedDescription)
        }
    }

    func selectedURL(for columnIndex: Int) -> URL? {
        guard selectedURLsByColumn.indices.contains(columnIndex) else {
            return nil
        }

        return selectedURLsByColumn[columnIndex]
    }

    func selectedEntry(in columnIndex: Int) -> FileSystemEntry? {
        guard columns.indices.contains(columnIndex), let selectedURL = selectedURL(for: columnIndex) else {
            return nil
        }

        return columns[columnIndex].entries.first(where: { $0.url == selectedURL })
    }

    func stageSelection(in columnIndex: Int) {
        guard columns.indices.contains(columnIndex), let entry = selectedEntry(in: columnIndex) else {
            return
        }

        stagedMove = StagedMove(
            entry: entry,
            sourceDirectoryURL: columns[columnIndex].directoryURL
        )
    }

    func clearStagedMove() {
        stagedMove = nil
    }

    func canMoveStagedItem(to destinationDirectoryURL: URL) -> Bool {
        guard let stagedMove else {
            return false
        }

        if stagedMove.sourceDirectoryURL == destinationDirectoryURL {
            return false
        }

        if stagedMove.entry.isDirectory && fileSystemService.isDescendant(destinationDirectoryURL, of: stagedMove.entry.url) {
            return false
        }

        return true
    }

    func moveStagedItem(to destinationDirectoryURL: URL) {
        guard let stagedMove else {
            return
        }

        guard canMoveStagedItem(to: destinationDirectoryURL) else {
            presentError(
                title: "Move Blocked",
                message: "Choose a different destination column for this item."
            )
            return
        }

        do {
            try fileSystemService.moveItem(
                at: stagedMove.entry.url,
                to: destinationDirectoryURL
            )

            self.stagedMove = nil
            expandedFolderPath = []
            selectedURLsByColumn = []
            try rebuildColumns()
        } catch {
            presentError(title: "Move Failed", message: error.localizedDescription)
        }
    }

    func open(_ entry: FileSystemEntry) {
        guard !entry.isDirectory else {
            return
        }

        openURL(entry.url)
    }

    func openWithDefaultApp(_ entry: FileSystemEntry) {
        guard !entry.isDirectory else {
            return
        }

        openURL(entry.url)
    }

    func revealInFinder(_ entry: FileSystemEntry) {
        NSWorkspace.shared.activateFileViewerSelecting([entry.url])
    }

    func copyPath(_ entry: FileSystemEntry) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(entry.url.path, forType: .string)
    }

    func dismissAlert() {
        alertContext = nil
    }

    private func rebuildColumns() throws {
        guard let rootURL else {
            columns = []
            return
        }

        var rebuiltColumns: [DirectorySnapshot] = [try fileSystemService.loadDirectory(at: rootURL)]
        var validExpandedFolders: [URL] = []

        for folderURL in expandedFolderPath {
            guard
                let parentColumn = rebuiltColumns.last,
                parentColumn.entries.contains(where: { $0.url == folderURL && $0.isDirectory })
            else {
                break
            }

            rebuiltColumns.append(try fileSystemService.loadDirectory(at: folderURL))
            validExpandedFolders.append(folderURL)
        }

        expandedFolderPath = validExpandedFolders
        columns = rebuiltColumns
        selectedURLsByColumn = Array(selectedURLsByColumn.prefix(columns.count))

        for index in columns.indices where selectedURLsByColumn.indices.contains(index) {
            guard let selectedURL = selectedURLsByColumn[index] else {
                continue
            }

            if !columns[index].entries.contains(where: { $0.url == selectedURL }) {
                selectedURLsByColumn[index] = nil
            }
        }

        if let stagedMove, !FileManager.default.fileExists(atPath: stagedMove.entry.url.path) {
            self.stagedMove = nil
        }
    }

    private func beginScopedAccess(to url: URL) {
        endScopedAccess()
        scopedRootURL = url
        isAccessingScopedResource = url.startAccessingSecurityScopedResource()
    }

    private func endScopedAccess() {
        if isAccessingScopedResource {
            scopedRootURL?.stopAccessingSecurityScopedResource()
        }

        scopedRootURL = nil
        isAccessingScopedResource = false
    }

    private func presentError(title: String, message: String) {
        alertContext = AlertContext(title: title, message: message)
    }

    private func openURL(_ url: URL) {
        guard NSWorkspace.shared.open(url) else {
            presentError(
                title: "Open Failed",
                message: "Neo Files couldn't open \(url.lastPathComponent)."
            )
            return
        }
    }
}
