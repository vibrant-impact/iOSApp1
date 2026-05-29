//
//  ContentView.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-21.
//

import SwiftUI
import Combine

struct ContentView: View {
    // MARK: - App State Providers
    @StateObject private var appStore = OrderStore()
    @State private var runSequenceStarted = false
    @State private var showingAddOrderForm = false
    @State private var runTimerActive = false
    @State private var isManifestLocked = false
    @State private var selectedOrderToEdit: TeamOrder?
    
    var body: some View {
        Group {
            if runTimerActive {
                // PHASE 3: Active Countdown Timer Loop
                TimerView(appStore: appStore, isRunActive: $runTimerActive)
                    .onDisappear {
                        isManifestLocked = false
                        runSequenceStarted = false
                    }
            } else if !runSequenceStarted {
                // PHASE 1: Isolated Home Welcome Screen View Component
                WelcomeView(
                    runSequenceStarted: $runSequenceStarted,
                    isManifestLocked: $isManifestLocked
                )
            } else {
                // PHASE 2: Isolated Dynamic Group Building Screen View Component
                ManifestBuilderView(
                    appStore: appStore,
                    runSequenceStarted: $runSequenceStarted,
                    runTimerActive: $runTimerActive,
                    isManifestLocked: $isManifestLocked,
                    selectedOrderToEdit: $selectedOrderToEdit,
                    showingAddOrderForm: $showingAddOrderForm
                )
            }
        }
    }
}
#Preview {
    ContentView()
}
