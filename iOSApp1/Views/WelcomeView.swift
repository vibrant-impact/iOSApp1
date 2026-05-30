//
//  WelcomeView.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-28.
//

import SwiftUI

struct WelcomeView: View {
    // Binding allows this subview to signal ContentView to change phases
    @Binding var runSequenceStarted: Bool
    @Binding var isManifestLocked: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Infinite loop animation container:
            LoopingVideoPlayerView(welcomeAnimation: "welcomeAnimation")
                .frame(width: 400, height: 400)
                .cornerRadius(20)
            
            Text("Tims Coffee Runner")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(.timsDarkBrown)
            
            Text("Ditch the scrap paper. Track preferences, coordinate runs, and earn rewards.")
                .font(.body)
                .foregroundColor(.brown)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            Button(action: {
                // FIXED: Quietly shuts down the ambient engine loop when changing screens!
                SoundManager.shared.stopBackgroundLoop()
                            
                SoundManager.shared.playSound(named: "click", withExtension: "mp3")
                runSequenceStarted = true
            }) {
                Text("Start New Run Order")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.timsRed)
                    .cornerRadius(14)
                    .shadow(color: Color.timsRed.opacity(0.35), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color.timsTan) // Unified cozy background palette
        // ==========================================
        // FIXED MULTIMEDIA LIFECYCLE CONTROLS
        // ==========================================
        .onAppear {
            // 1. Honk the horn once right at boot-up setup!
            SoundManager.shared.playSound(named: "car-horn", withExtension: "mp3")
                        
            // 2. Queue up the ambient looping engine track at a subtle volume scale after 0.4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                SoundManager.shared.startBackgroundLoop(named: "engine", withExtension: "mp3", volume: 0.15)
            }
        }
    }
}
