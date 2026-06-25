import AVFoundation
import AVKit
import SwiftUI

struct VideoPreviewView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> AVPlayerView {
        let playerView = AVPlayerView()
        playerView.controlsStyle = .inline
        playerView.showsSharingServiceButton = false
        playerView.showsFrameSteppingButtons = false
        playerView.updatesNowPlayingInfoCenter = false
        playerView.allowsPictureInPicturePlayback = false
        playerView.videoGravity = .resizeAspect
        playerView.player = makePlayer(for: url)
        return playerView
    }

    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        guard let currentAsset = (nsView.player?.currentItem?.asset as? AVURLAsset)?.url else {
            nsView.player = makePlayer(for: url)
            return
        }

        if currentAsset != url {
            nsView.player?.pause()
            nsView.player = makePlayer(for: url)
        }
    }

    static func dismantleNSView(_ nsView: AVPlayerView, coordinator: ()) {
        nsView.player?.pause()
        nsView.player = nil
    }

    private func makePlayer(for url: URL) -> AVPlayer {
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .pause
        return player
    }
}
