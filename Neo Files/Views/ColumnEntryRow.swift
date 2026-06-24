import SwiftUI

struct ColumnEntryRow: View {
    let entry: FileSystemEntry
    let isSelected: Bool
    let isStaged: Bool
    let onSelect: () -> Void
    let onOpen: () -> Void
    let onOpenWithDefaultApp: () -> Void
    let onRevealInFinder: () -> Void
    let onCopyPath: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: entry.symbolName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(NeoPalette.primary)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.displayName)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(NeoPalette.primary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(entry.detailLabel)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(NeoPalette.secondary)

                        if isStaged {
                            Text("MOVE")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundStyle(NeoPalette.primary)
                        }
                    }
                }

                Spacer(minLength: 8)

                if entry.isDirectory {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(NeoPalette.secondary)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? NeoPalette.selection : NeoPalette.panelSecondary.opacity(0.65))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? NeoPalette.primary : NeoPalette.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            if !entry.isDirectory {
                Button("Open") {
                    onOpen()
                }

                Button("Open with Default App") {
                    onOpenWithDefaultApp()
                }

                Divider()

                Button("Reveal in Finder") {
                    onRevealInFinder()
                }

                Button("Copy Path") {
                    onCopyPath()
                }
            }
        }
    }
}
