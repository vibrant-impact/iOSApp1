//
//  SoundManager.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-29.
//

import Foundation
import AVFoundation

class SoundManager {
    // Singleton instance to access this manager anywhere in the app effortlessly
    static let shared = SoundManager()
    
    // Internal player instance tracking the active audio stream container
    private var audioPlayer: AVAudioPlayer?
    
    /// Plays an audio file from the local app bundle
    /// - Parameters:
    ///   - fileName: The exact string text name of your audio file (e.g., "clickEffect")
    ///   - fileType: The extension format string of the target file (e.g., "mp3", "wav")
    func playSound(named fileName: String, withExtension fileType: String = "mp3") {
        // 1. Locate the file within the main resource bundle directory framework
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("⚠️ Sound Error: Could not find \(fileName).\(fileType) in the app bundle resources.")
            return
        }
        
        do {
            // 2. Initialize the system player with our file path pointer target
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            
            // 3. Pre-prepare the hardware buffers to guarantee instant execution latency when tapped
            audioPlayer?.prepareToPlay()
            
            // 4. Spin up the play trigger
            audioPlayer?.play()
        } catch {
            print("⚠️ Sound Error: Failed to execute audio playback instantiation: \(error.localizedDescription)")
        }
    }
}
