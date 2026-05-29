//
//  LoopingVideoPlayerView.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-28.
//

import SwiftUI
import AVFoundation

struct LoopingVideoPlayerView: UIViewRepresentable {
    let welcomeAnimation: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        // Locate the mp4 asset directly inside the primary app bundle directory
        guard let url = Bundle.main.url(forResource: welcomeAnimation, withExtension: "mp4") else {
            print("⚠️ Video Error: Unable to locate \(welcomeAnimation).mp4 inside app tree bundle")
            return view
        }
        
        // Initialize player layers
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.backgroundColor = UIColor.clear.cgColor
        view.layer.addSublayer(playerLayer)
        
        // Create an explicit notification observer loop to catch the video end stamp and rewind it instantly
        context.coordinator.notificationObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }
        
        // Spin up execution play triggers
        player.play()
        
        // Attach references back to coordinate lifecycles safely
        context.coordinator.player = player
        context.coordinator.playerLayer = playerLayer
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Dynamically adjust internal boundaries to match size changes
        DispatchQueue.main.async {
            context.coordinator.playerLayer?.frame = uiView.bounds
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var player: AVPlayer?
        var playerLayer: AVPlayerLayer?
        var notificationObserver: NSObjectProtocol?
        
        deinit {
            if let observer = notificationObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
}
