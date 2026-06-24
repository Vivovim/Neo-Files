import SwiftUI

struct BrowserColumnView: View {
    let column: DirectorySnapshot
    let selectedURL: URL?
    let selectedEntry: FileSystemEntry?
    let stagedMove: StagedMove?
    let canMoveHere: Bool
    let onSelect: (FileSystemEntry) -> Void
    let onStageSelection: () -> Void
    let onMoveHere: () -> Void
    let onOpen: (FileSystemEntry) -> Void
    let onOpenWithDefaultApp: (FileSystemEntry) -> Void
    let onRevealInFinder: (FileSystemEntry) -> Void
    let onCopyPath: (FileSystemEntry) -> Void

    private let badgeColumns = [GridItem(.adaptive(minimum: 70), spacing: 8, alignment: .leading)]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(column.title)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(NeoPalette.primary)

                        Text(column.directoryURL.neoDisplayPath)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(NeoPalette.secondary)
                            .lineLimit(1)
                            .textSelection(.enabled)
                    }

                    Spacer(minLength: 10)

                    if stagedMove != nil {
                        Button("Move Here") {
                            onMoveHere()
                        }
                        .buttonStyle(NeoButtonStyle())
                        .disabled(!canMoveHere)
                    }
                }

                Text("Folders \(column.summary.folderCount)  |  Files \(column.summary.totalFileCount)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(NeoPalette.secondary)

                if column.summary.fileTypes.isEmpty {
                    Text("No files in this view")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(NeoPalette.secondary.opacity(0.8))
                } else {
                    LazyVGrid(columns: badgeColumns, alignment: .leading, spacing: 8) {
                        ForEach(column.summary.fileTypes) { item in
                            HStack(spacing: 6) {
                                Text(item.type)
                                Text("\(item.count)")
                            }
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(NeoPalette.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(NeoPalette.panelSecondary)
                            )
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(NeoPalette.border, lineWidth: 1)
                            )
                        }
                    }
                }

                HStack {
                    Button(selectedEntry == nil ? "Select an Item" : "Stage Move") {
                        onStageSelection()
                    }
                    .buttonStyle(NeoButtonStyle())
                    .disabled(selectedEntry == nil)

                    if let stagedMove, stagedMove.entry.url == selectedEntry?.url {
                        Text("Queued")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundStyle(NeoPalette.secondary)
                    }
                }
            }

            Divider()
                .overlay(NeoPalette.border)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(column.entries) { entry in
                        ColumnEntryRow(
                            entry: entry,
                            isSelected: selectedURL == entry.url,
                            isStaged: stagedMove?.entry.url == entry.url,
                            onSelect: { onSelect(entry) },
                            onOpen: { onOpen(entry) },
                            onOpenWithDefaultApp: { onOpenWithDefaultApp(entry) },
                            onRevealInFinder: { onRevealInFinder(entry) },
                            onCopyPath: { onCopyPath(entry) }
                        )
                    }
                }
                .padding(.bottom, 4)
            }
        }
        .padding(18)
        .frame(width: 310, alignment: .topLeading)
        .frame(minHeight: 620, alignment: .topLeading)
        .neoPanel()
    }
}
