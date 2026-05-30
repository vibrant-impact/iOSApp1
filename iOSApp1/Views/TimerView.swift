//
//  TimerView.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-22.
//

import SwiftUI
import Combine

struct TimerView: View {
    @ObservedObject var appStore: OrderStore
    @Binding var isRunActive: Bool
    
    let targetTimeLimit = 900 // 15 minutes in seconds
    @State private var secondsElapsed = 0
    @State private var isRunCompleted = false
    @State private var showSummaryAlert = false
    @State private var earnedCreditStatus = false
    
    let activeTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Computes dynamic display values
    var secondsRemaining: Int {
        max(0, targetTimeLimit - secondsElapsed)
    }
    
    var formattedTime: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ZStack {
            // Background View Layer
            Image("brownSwirlBackground")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("🚘")
                    .font(.system(size: 78))
                
                Text("Run in Progress!")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.timsGold)
                
                Text("Runner: \(appStore.currentRunner)")
                    .font(.title2)
                    .foregroundColor(.timsTan)
                
                // Clock Timer Display Layout
                VStack {
                    if secondsElapsed <= targetTimeLimit {
                        Text(formattedTime)
                            .font(.system(size: 72, weight: .black, design: .rounded))
                            .foregroundColor(.orange)
                        Text("Time left for a free drink credit!")
                            .font(.subheadline)
                            .foregroundColor(.timsTan)
                    } else {
                        let overage = secondsElapsed - targetTimeLimit
                        Text("+\(overage / 60):\(String(format: "%02d", overage % 60))")
                            .font(.system(size: 72, weight: .black, design: .rounded))
                            .foregroundColor(.timsRed)
                        Text("Run Time Exceeded Limit")
                            .font(.subheadline)
                            .foregroundColor(.timsRed)
                    }
                }
                .padding()
                
                // Complete Run Trigger Button
                if !showSummaryAlert {
                    Button(action: {
                        // FIXED: Saves the final metric state status before freezing layout frames
                        earnedCreditStatus = secondsRemaining > 0
                        
                        if earnedCreditStatus {
                            SoundManager.shared.playSound(named: "success", withExtension: "mp3")
                        } else {
                            SoundManager.shared.playSound(named: "pop", withExtension: "mp3")
                        }
                        
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                            showSummaryAlert = true // Triggers pop up modal presentation card safely
                        }
                    }) {
                        Label("I'm Back! Complete Run", systemImage: "cup.and.saucer.fill")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(.timsDarkBrown)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(14)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 32)
                }
            }
            .blur(radius: showSummaryAlert ? 5 : 0) // Smooth backdrop blur when pop up shows
            
            // ==========================================
            // FIXED: Animated Pop Up Card Overlay Layer
            // ==========================================
            if showSummaryAlert {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    
                VStack(spacing: 16) {
                    Text(earnedCreditStatus ? "🎉 Quick Run Reward!" : "☕ Run Completed!")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.timsDarkBrown)
                    
                    HStack {
                        Image(systemName: earnedCreditStatus ? "bolt.fill" : "hourglass.badge.plus")
                        Text(earnedCreditStatus ?
                             "Speed Run Finish: \(secondsElapsed / 60)m \(secondsElapsed % 60)s!" :
                             "Overage: +\( (secondsElapsed - targetTimeLimit) / 60)m \((secondsElapsed - targetTimeLimit) % 60)s")
                    }
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(earnedCreditStatus ? .green : .timsRed)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background((earnedCreditStatus ? Color.green : Color.timsRed).opacity(0.15))
                    .cornerRadius(8)
                    
                    Text(earnedCreditStatus ?
                         "\(appStore.currentRunner.isEmpty ? "Guest" : appStore.currentRunner) completed the run in under 15 minutes and earned 1 Free Drink Credit!" :
                         "Good effort! The manifest order run is complete. Time to hand out the coffees!")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.brown)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                    
                    Button(action: {
                        SoundManager.shared.playSound(named: "click", withExtension: "mp3")
                        
                        withAnimation(.easeInOut(duration: 0.25)) {
                            
                            // Automatically commits run history details and awards drink credits to the profile record!
                            if !appStore.currentRunner.isEmpty && appStore.currentRunner.lowercased() != "guest" {
                                appStore.awardDrinkCredit(
                                    to: appStore.currentRunner,
                                    elapsedSeconds: secondsElapsed,
                                    targetSeconds: targetTimeLimit,
                                    creditEarned: earnedCreditStatus
                                )
                            }
                            
                            appStore.resetActiveRun()
                            
                            showSummaryAlert = false
                            isRunActive = false // FIXED: Turns off navigation run sequence flag to snap cleanly back to welcome splash!
                        }
                    }) {
                        Text(earnedCreditStatus ? "Claim Reward! 🌟" : "Sweet! 🍩")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(earnedCreditStatus ? Color.orange : Color.timsDarkBrown)
                            .cornerRadius(10)
                            .shadow(color: (earnedCreditStatus ? Color.orange : Color.timsDarkBrown).opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
                .padding(24)
                .background(Color.timsTan)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 36)
                .transition(.scale.combined(with: .opacity))
            }
        }
        // ==========================================
        // FIXED: Listens to Live System Clock Ticks
        // ==========================================
        .onReceive(activeTimer) { _ in
            if !showSummaryAlert { // Stops accumulating seconds once they hit 'I'm Back!'
                secondsElapsed += 1
            }
        }
    }
}
