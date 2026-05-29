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
            
            // Custom App Graphic Asset:
            Image("welcomeHeroLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
            
            Text("Tims Coffee Runner")
                .font(.system(size: 32, weight: .black, design: .rounded))
            
            Text("Ditch the scrap paper. Track preferences, coordinate runs, and earn rewards.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            Button(action: {
                // Mutates state variables on the parent ContentView
                isManifestLocked = false
                runSequenceStarted = true
            }) {
                Text("Start New Run Order")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.timsRed)
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 40)
        }
    }
}


