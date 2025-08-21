import SwiftUI
import AVFoundation

struct VideoPlayer: UIViewRepresentable {
    var videoURL: URL?
    
    class Coordinator: NSObject {
        var playerLayer: AVPlayerLayer?
        var player: AVPlayer?
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "bounds", let view = object as? UIView {
                DispatchQueue.main.async {
                    self.playerLayer?.frame = view.bounds
                    print("Updated player layer frame to: \(view.bounds)")
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .red // Debug color to confirm view exists
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Clear any existing player layers
        context.coordinator.playerLayer?.removeFromSuperlayer()
        
        guard let videoURL = videoURL else { return }
        
        // Create new player
        let player = AVPlayer(url: videoURL)
        context.coordinator.player = player
        
        // Create and add player layer
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = uiView.bounds
        uiView.layer.addSublayer(playerLayer)
        
        // Store reference to player layer
        context.coordinator.playerLayer = playerLayer
        
        // Add observer for layout changes
        uiView.addObserver(context.coordinator, forKeyPath: "bounds", options: [.new], context: nil)
        
        print("Initial view bounds: \(uiView.bounds)")
        print("Set player layer frame to: \(playerLayer.frame)")
        
        // Start playback
        player.play()
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        uiView.removeObserver(coordinator, forKeyPath: "bounds")
        coordinator.playerLayer?.removeFromSuperlayer()
        coordinator.player?.pause()
    }
}
