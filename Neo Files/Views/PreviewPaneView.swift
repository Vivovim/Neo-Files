import SwiftUI

struct PreviewPaneView: View {
    let entry: FileSystemEntry?
    let onOpen: (FileSystemEntry) -> Void
    let onRevealInFinder: (FileSystemEntry) -> Void
    let onCopyPath: (FileSystemEntry) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            if let entry {
                actionBar(for: entry)
            }

            previewContent
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            detailsSection
        }
        .padding(18)
        .frame(width: 420, alignment: .topLeading)
        .frame(minHeight: 620, alignment: .topLeading)
        .neoPanel()
    }
}

private extension PreviewPaneView {
    var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preview")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(NeoPalette.primary)

            if let entry {
                Text(entry.displayName)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(NeoPalette.primary)
                    .lineLimit(1)

                Text(entry.url.neoDisplayPath)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(NeoPalette.secondary)
                    .textSelection(.enabled)
                    .lineLimit(3)

                kindBadge(for: entry)
            } else {
                Text("Select something in the browser to inspect it here.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(NeoPalette.secondary)
            }
        }
    }

    @ViewBuilder
    func actionBar(for entry: FileSystemEntry) -> some View {
        HStack(spacing: 10) {
            if !entry.isDirectory {
                Button("Open") {
                    onOpen(entry)
                }
                .buttonStyle(NeoButtonStyle())
            }

            Button("Reveal in Finder") {
                onRevealInFinder(entry)
            }
            .buttonStyle(NeoButtonStyle())

            Button("Copy Path") {
                onCopyPath(entry)
            }
            .buttonStyle(NeoButtonStyle())
        }
    }

    @ViewBuilder
    var previewContent: some View {
        if let entry {
            if entry.isDirectory {
                placeholder(
                    title: "Folder selected",
                    message: "This pane is acting like an inspector right now. Browse deeper or pick a file to load a Quick Look preview."
                )
            } else if entry.isAudioFile {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 10) {
                        Image(systemName: "waveform.circle.fill")
                            .font(.system(size: 28, weight: .black))
                            .foregroundStyle(NeoPalette.primary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Audio Preview")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(NeoPalette.primary)

                            Text("Playback is handled inline here so you can audition audio without leaving Neo Files.")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(NeoPalette.secondary)
                        }
                    }

                    AudioPreviewView(url: entry.url)
                        .frame(height: 90)
                        .previewSurface()
                }
            } else if entry.isVideoFile {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 10) {
                        Image(systemName: "film.circle.fill")
                            .font(.system(size: 28, weight: .black))
                            .foregroundStyle(NeoPalette.primary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Video Preview")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(NeoPalette.primary)

                            Text("Playback is handled inline here for `.mp4`, `.m4v`, `.mov`, and other video files.")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(NeoPalette.secondary)
                        }
                    }

                    VideoPreviewView(url: entry.url)
                        .frame(height: 250)
                        .previewSurface()
                }
            } else {
                QuickLookPreviewView(url: entry.url)
                    .previewSurface()
            }
        } else {
            placeholder(
                title: "Inspector Ready",
                message: "Select a file from any column to see a Quick Look preview and metadata. `.txt`, `.jpg`, `.png`, `.mp3`, and `.mov` are great starting points."
            )
        }
    }

    @ViewBuilder
    var detailsSection: some View {
        if let entry {
            VStack(alignment: .leading, spacing: 14) {
                Text("Details")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(NeoPalette.secondary)

                VStack(alignment: .leading, spacing: 12) {
                    metadataRow(label: "Kind", value: entry.inspectorKindLabel)
                    metadataRow(label: "Modified", value: entry.contentModifiedDate?.formatted(date: .abbreviated, time: .shortened) ?? "Unknown")

                    if let fileSize = entry.fileSize, !entry.isDirectory {
                        metadataRow(label: "Size", value: ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file))
                    }

                    if let contentTypeIdentifier = entry.contentTypeIdentifier {
                        metadataRow(label: "UTI", value: contentTypeIdentifier)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(NeoPalette.panelSecondary.opacity(0.55))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(NeoPalette.border, lineWidth: 1)
            )
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("Hints")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(NeoPalette.secondary)

                Text("The inspector follows the deepest selected item in the column browser.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(NeoPalette.secondary)

                Text("Use the explicit Open button when you want the file’s default app. Previewing alone will stay inside Neo Files.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(NeoPalette.secondary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(NeoPalette.panelSecondary.opacity(0.55))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(NeoPalette.border, lineWidth: 1)
            )
        }
    }

    func placeholder(title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer(minLength: 0)

            Image(systemName: entry?.symbolName ?? "doc.text.image")
                .font(.system(size: 30, weight: .black))
                .foregroundStyle(NeoPalette.primary)

            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(NeoPalette.primary)

            Text(message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(NeoPalette.secondary)
                .frame(maxWidth: 320, alignment: .leading)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(NeoPalette.panelSecondary.opacity(0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(NeoPalette.border, lineWidth: 1)
        )
    }

    func kindBadge(for entry: FileSystemEntry) -> some View {
        Text(entry.detailLabel)
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

    func metadataRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(NeoPalette.secondary)
                .frame(width: 72, alignment: .leading)

            Text(value)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(NeoPalette.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
    }
}

private extension View {
    func previewSurface() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(NeoPalette.panelSecondary.opacity(0.75))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(NeoPalette.border, lineWidth: 1)
            )
    }
}
