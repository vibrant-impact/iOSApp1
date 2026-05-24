//
//  ContentView.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-21.
//

import SwiftUI
import Combine

import SwiftUI

struct ContentView: View {
    // App State Properties
    @StateObject private var appStore = OrderStore()
    @State private var runSequenceStarted = false
    @State private var showingAddOrderForm = false
    @State private var runTimerActive = false
    @State private var isManifestLocked = false
    @State private var selectedOrderToEdit: TeamOrder?
    
    var body: some View {
        Group {
            // PHASE 3: Active Run Timer Window Mode
            if runTimerActive {
                TimerView(appStore: appStore, isRunActive: $runTimerActive)
                    .onDisappear {
                        // FUNCTIONAL RESET: When the timer finishes and dismisses, go back to the home welcome screen.
                        isManifestLocked = false
                        runSequenceStarted = false
                    }
            } else if !runSequenceStarted {
                // PHASE 1: Welcome Screen
                VStack(spacing: 24) {
                    Spacer()
                    Image(systemName: "car.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                        .foregroundColor(.red)
                    
                    Text("Tims Coffee Runner")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                    
                    Text("Ditch the scrap paper. Track preferences, coordinate runs, and earn rewards.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Initiates a fresh, clean ordering array loop
                    Button(action: {
                        isManifestLocked = false
                        runSequenceStarted = true
                    }) {
                        Text("Start New Run Order")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(14)
                            .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 40)
                }
            } else {
                // PHASE 2: Order Building
                NavigationView {
                    VStack {
                        List {
                            // Section title dynamically adjusts based on step visibility state
                            Section(header: Text(isManifestLocked ? "Current Group Orders" : "Current Group Orders (Tap to Edit)")) {
                                if appStore.activeOrders.isEmpty {
                                    Text("No orders added yet. Tap '+' below to begin.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                } else {
                                    // Loop through all currently added individual team orders
                                    ForEach(appStore.activeOrders) { order in
                                        Button(action: {
                                            // Edits are only permitted if the run layout isn't locked in yet
                                            if !isManifestLocked {
                                                selectedOrderToEdit = order
                                                showingAddOrderForm = true
                                            }
                                        }) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(order.name)
                                                    .font(.headline)
                                                    .foregroundColor(.primary) // Keeps text dark inside list buttons
                                                
                                                Text("☕ \(order.drink.quantity)x \(order.drink.itemName) (\(order.drink.notes.isEmpty ? "No Notes" : order.drink.notes))")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                
                                                if order.food.itemName != "None" {
                                                    Text("🍩 \(order.food.quantity)x \(order.food.itemName) (\(order.food.notes.isEmpty ? "No Notes" : order.food.notes))")
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                    // Enables swipe-to-delete
                                    .onDelete(perform: deleteOrderFromActiveRun)
                                }
                            }
                            // SUB-PHASE: Exposed runner assignment dropdown (reveals only when orders are locked in)
                            if isManifestLocked {
                                Section(header: Text("📋 Select the Designated Runner")) {
                                    Picker("Who is driving?", selection: $appStore.currentRunner) {
                                        Text("Choose Runner...").tag("")
                                        // Populates runner options dynamically strictly from current active names
                                        ForEach(appStore.activeOrderNames, id: \.self) { name in
                                            Text(name).tag(name)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                        
                        // Base Footer Buttons
                        VStack(spacing: 12) {
                            if !isManifestLocked {
                                // Trigger button to load or construct a brand new individual item sheet modal
                                HStack(spacing: 16) {
                                    Button(action: {
                                        selectedOrderToEdit = nil // Explicitly tell sheet we are making a NEW order
                                        showingAddOrderForm = true
                                    }) {
                                        Label("Add Item", systemImage: "plus")
                                            .font(.headline)
                                            .foregroundColor(.red)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.red.opacity(0.1))
                                            .cornerRadius(12)
                                    }
                                    
                                    // Locks group order changes and advances setup sequence forward to runner assignment
                                    Button(action: { isManifestLocked = true }) {
                                        Text("Ready to Run!")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(appStore.activeOrders.isEmpty ? Color.gray : Color.green)
                                            .cornerRadius(12)
                                    }
                                    .disabled(appStore.activeOrders.isEmpty)
                                }
                            } else {
                                HStack(spacing: 16) {
                                    // Step backwards option to let team members add more items or tweak selections
                                    Button(action: { isManifestLocked = false }) {
                                        Text("Unlock & Edit")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color(.systemGray5))
                                            .cornerRadius(12)
                                    }
                                    // Final step button to trigger the countdown timer
                                    Button(action: { runTimerActive = true }) {
                                        Text("🚀 Start Clock")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(appStore.currentRunner.isEmpty ? Color.gray : Color.green)
                                            .cornerRadius(12)
                                    }
                                    .disabled(appStore.currentRunner.isEmpty)
                                }
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("Add Orders")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel Setup") { runSequenceStarted = false }
                        }
                    }
                    // Controls modal item presentation for creating or tweaking orders
                    .sheet(isPresented: $showingAddOrderForm) {
                        AddOrderView(appStore: appStore, orderToEdit: selectedOrderToEdit)
                    }
                }
            }
        }
    }
    // Helper Methods
    // Removes an item directly out of the active log by tracking its index
    private func deleteOrderFromActiveRun(at offsets: IndexSet) {
        appStore.activeOrders.remove(atOffsets: offsets)
        // Safety validation checklist step: if the designated runner is deleted, reset the assignment selection
        if !appStore.activeOrderNames.contains(appStore.currentRunner) {
            appStore.currentRunner = ""
        }
    }
}
#Preview {
    ContentView()
}
