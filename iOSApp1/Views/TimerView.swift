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
            
        VStack(spacing: 30) {
            Text("☕ Run in Progress!")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white) // Switch text to white for legibility
                
            Text("Runner: \(appStore.currentRunner)")
                .font(.title2)
                .foregroundColor(.gray)
                
            VStack {
                if secondsElapsed <= targetTimeLimit {
                    Text(formattedTime)
                        .font(.system(size: 72, weight: .black, design: .rounded))
                        .foregroundColor(.green)
                    Text("Time left for a free drink credit!")
                        .font(.subheadline)
                        .foregroundColor(.gray) // Use a lighter gray style
                } else {
                    let overage = secondsElapsed - targetTimeLimit
                    Text("+\(overage / 60):\(String(format: "%02d", overage % 60))")
                        .font(.system(size: 72, weight: .black, design: .rounded))
                        .foregroundColor(.red)
                    Text("Run Time Exceeded Limit")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
            .padding()
                
            Button(action: {
                earnedCreditStatus = secondsElapsed <= targetTimeLimit
                let totalItems = appStore.activeOrders.count
                let summary = CompletedRunSummary(
                    dateCompleted: Date(),
                    runnerName: appStore.currentRunner,
                    totalItemsOrdered: totalItems,
                    timeTakenSeconds: secondsElapsed,
                    earnedCredit: earnedCreditStatus
                )
                appStore.runHistory.append(summary)
                showSummaryAlert = true
            }) {
                HStack {
                    Image(systemName: "cup.and.saucer.fill")
                    Text("I'm Back! Complete Run")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(15)
            }
            .padding(.horizontal)
        }
        .onReceive(activeTimer) { _ in
            if !isRunCompleted {
                secondsElapsed += 1
            }
        }
        .alert(isPresented: $showSummaryAlert) {
            Alert(
                title: Text(earnedCreditStatus ? "🎉 Quick Run Reward!" : "Welcome Back!"),
                message: Text(earnedCreditStatus ? "\(appStore.currentRunner) completed the run in under 15 minutes and earned 1 Free Drink Credit!" : "Run completed in \(secondsElapsed / 60)m \(secondsElapsed % 60)s."),
                dismissButton: .default(Text("Awesome"), action: {
                    appStore.resetActiveRun()
                    isRunActive = false
                })
            )
        }
    }
}
