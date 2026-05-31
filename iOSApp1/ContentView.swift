//
//  ContentView.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-21.
//

import SwiftUI
import Combine

struct ContentView: View {
    // Central data engine and state control parameters for managing the active coffee run sequence
    @StateObject private var appStore = OrderStore()
    @State private var runSequenceStarted = false
    @State private var showingAddOrderForm = false
    @State private var runTimerActive = false
    @State private var isManifestLocked = false
    @State private var selectedOrderToEdit: TeamOrder?
    
    var body: some View {
        Group {
            if runTimerActive {
                // Active countdown challenge screen checking speed metrics against the timer loop
                TimerView(appStore: appStore, isRunActive: $runTimerActive)
                    .onDisappear {
                        // Reset structural flags when the timer screen unmounts from the view tree
                        isManifestLocked = false
                        runSequenceStarted = false
                    }
            } else if !runSequenceStarted {
                // Initial launch dashboard overlay displaying onboarding animations and user options
                WelcomeView(
                    runSequenceStarted: $runSequenceStarted,
                    isManifestLocked: $isManifestLocked
                )
            } else {
                // Active group listing sheet canvas for managing baskets and modifying team records
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
