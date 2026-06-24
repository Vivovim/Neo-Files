import QuickLookUI
import SwiftUI

struct QuickLookPreviewView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> QLPreviewView {
        let previewView = QLPreviewView(frame: .zero, style: .normal)!
        previewView.shouldCloseWithWindow = true
        previewView.autostarts = false
        previewView.previewItem = url as NSURL
        return previewView
    }

    func updateNSView(_ nsView: QLPreviewView, context: Context) {
        let previewURL = url as NSURL
        let currentURL = nsView.previewItem as? NSURL

        if currentURL != previewURL {
            nsView.previewItem = previewURL
        }
    }
}
