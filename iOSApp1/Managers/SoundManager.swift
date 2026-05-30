//
//  SoundManager.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-29.
//

import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    // Primary audio track channel for standard button interaction clicks/pops
    private var audioPlayer: AVAudioPlayer?
    
    // FIXED: Dedicated secondary playback instance strictly tracking background loops
    // to prevent ambient tracks from cutting off snappy button click effects!
    private var ambientLoopPlayer: AVAudioPlayer?
    
    /// Plays an audio file once from the local app bundle (for snappy clicks/pops)
    func playSound(named fileName: String, withExtension fileType: String = "mp3") {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("⚠️ Sound Error: Could not find \(fileName).\(fileType) in bundle.")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("⚠️ Sound Error: Playback failed: \(error.localizedDescription)")
        }
    }
    
    /// FIXED: Starts an infinite looping background track on a completely separate playback stream channel
    /// - Parameters:
    ///   - fileName: The file name string text (e.g., "engine")
    ///   - volume: A float setting between 0.0 (silent) to 1.0 (full blast) to keep backgrounds subtle
    func startBackgroundLoop(named fileName: String, withExtension fileType: String = "mp3", volume: Float = 0.3) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("⚠️ Sound Loop Error: Unable to locate \(fileName).\(fileType)")
            return
        }
        
        do {
            ambientLoopPlayer = try AVAudioPlayer(contentsOf: url)
            
            // FIXED: Setting numberOfLoops to -1 tells iOS to loop this track infinitely!
            ambientLoopPlayer?.numberOfLoops = -1
            ambientLoopPlayer?.volume = volume // Keeps the engine purr soft and non-distracting
            ambientLoopPlayer?.prepareToPlay()
            ambientLoopPlayer?.play()
            print("🔊 Ambient Loop Started: Infinite playback initialized for \(fileName).mp4")
        } catch {
            print("⚠️ Sound Loop Error: Failed to start loop: \(error.localizedDescription)")
        }
    }
    
    /// FIXED: Safely silences and unloads the background loop when navigating away from the dashboard phase
    func stopBackgroundLoop() {
        if ambientLoopPlayer?.isPlaying == true {
            ambientLoopPlayer?.stop()
            ambientLoopPlayer = nil
            print("🤫 Ambient Loop Silenced: Unloaded background stream.")
        }
    }
}
