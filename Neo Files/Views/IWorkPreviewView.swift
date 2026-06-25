import AppKit
import QuickLookThumbnailing
import SwiftUI

struct IWorkPreviewView: View {
    let url: URL

    @State private var previewImage: NSImage?
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        ZStack {
            if let previewImage {
                GeometryReader { geometry in
                    Image(nsImage: previewImage)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            maxWidth: geometry.size.width,
                            maxHeight: geometry.size.height,
                            alignment: .center
                        )
                        .padding(24)
                }
            } else if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .controlSize(.large)

                    Text("Loading document preview…")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(NeoPalette.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.image")
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(NeoPalette.primary)

                    Text("Preview unavailable")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(NeoPalette.primary)

                    Text(errorMessage ?? "Neo Files could not render a preview thumbnail for this document.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(NeoPalette.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 280)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(24)
            }
        }
        .task(id: url) {
            await loadPreview()
        }
    }

    private func loadPreview() async {
        isLoading = true
        errorMessage = nil
        previewImage = nil

        let didStartScopedAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didStartScopedAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            previewImage = try await generateThumbnail()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func generateThumbnail() async throws -> NSImage {
        try await withCheckedThrowingContinuation { continuation in
            let request = QLThumbnailGenerator.Request(
                fileAt: url,
                size: CGSize(width: 1400, height: 1400),
                scale: 2,
                representationTypes: .all
            )

            QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { thumbnail, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let thumbnail else {
                    continuation.resume(
                        throwing: CocoaError(.fileReadUnknown)
                    )
                    return
                }

                continuation.resume(returning: thumbnail.nsImage)
            }
        }
    }
}
