//
//  ManifestBuilderView.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-28.
//

import SwiftUI

struct ManifestBuilderView: View {
    @ObservedObject var appStore: OrderStore
    
    // Bindings to manage navigation state from the main container hub
    @Binding var runSequenceStarted: Bool
    @Binding var runTimerActive: Bool
    @Binding var isManifestLocked: Bool
    @Binding var selectedOrderToEdit: TeamOrder?
    @Binding var showingAddOrderForm: Bool
    
    // Calculated cost totals for the shopping cart interface
    var runningGrandTotal: Double {
        appStore.activeOrders.reduce(0) { $0 + $1.checkoutTotal }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MASTER BACKGROUND LAYER: Injecting the rich, dark texture asset
                Image("brownSwirlBackground")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    List {
                        // Section: Order Registry Loop
                        Section(header: Text(isManifestLocked ? "Current Group Orders" : "Current Group Orders (Tap to Edit)")
                            .foregroundColor(.white.opacity(0.8)) // Dynamic text contrast adjustment
                        ) {
                            if appStore.activeOrders.isEmpty {
                                Text("No orders added yet. Tap 'Add Order' below to begin.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .listRowBackground(Color.white.opacity(0.85)) // Frosted translucent rows
                            } else {
                                ForEach(appStore.activeOrders) { order in
                                    Button(action: {
                                        if !isManifestLocked {
                                            selectedOrderToEdit = order
                                            showingAddOrderForm = true
                                        }
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(order.name)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                
                                                Text("☕ \(order.drink.quantity)x \(order.drink.itemName)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                
                                                if order.food.itemName != "None" {
                                                    Text("🍩 \(order.food.quantity)x \(order.food.itemName)")
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            Spacer()
                                            Text("$\(String(format: "%.2f", order.checkoutTotal))")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                                .onDelete(perform: deleteOrderFromActiveRun)
                                .listRowBackground(Color.white.opacity(0.85)) // Frosted translucent rows
                            }
                        }
                        
                        // Section: Totals Checkout Financial Ledger
                        if !appStore.activeOrders.isEmpty {
                            Section(header: Text("💰 Manifest Cost Summary").foregroundColor(.white.opacity(0.8))) {
                                HStack {
                                    Text("Estimated Run Total:")
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text("$\(String(format: "%.2f", runningGrandTotal))")
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                            }
                            .listRowBackground(Color.white.opacity(0.85))
                        }
                        
                        // Section: Contextual Runner Selector Dropdown (reveals only when locked)
                        if isManifestLocked {
                            Section(header: Text("📋 Select the Designated Runner").foregroundColor(.white.opacity(0.8))) {
                                Picker("Who is driving?", selection: $appStore.currentRunner) {
                                    Text("Choose Runner...").tag("")
                                    ForEach(appStore.activeOrderNames, id: \.self) { name in
                                        Text(name).tag(name)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                            .listRowBackground(Color.white.opacity(0.85))
                        }
                    }
                    .scrollContentBackground(.hidden) // STRIPS out the native system default gray card layers
                    .listStyle(.insetGrouped)
                    
                    // Action Control Tray Base Footer Buttons Container
                    VStack(spacing: 12) {
                        if !isManifestLocked {
                            HStack(spacing: 16) {
                                Button(action: {
                                    selectedOrderToEdit = nil
                                    showingAddOrderForm = true
                                }) {
                                    Label("Add Order", systemImage: "plus")
                                        .font(.headline)
                                        .foregroundColor(.timsRed)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white) // High-contrast solid button look over dark canvas
                                        .cornerRadius(12)
                                }
                                
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
                                Button(action: { isManifestLocked = false }) {
                                    Text("Unlock & Edit")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white.opacity(0.25)) // Blends nicely with swirl textures
                                        .cornerRadius(12)
                                }
                                
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
                    .background(.ultraThinMaterial) // Beautiful translucent frosting effect directly over the bottom swirl
                }
            }
            .navigationTitle("Add Orders")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel Setup") { runSequenceStarted = false }
                        .foregroundColor(.white) // Ensures bar buttons remain bright
                }
            }
            .sheet(isPresented: $showingAddOrderForm) {
                AddOrderView(appStore: appStore, orderToEdit: selectedOrderToEdit)
            }
        }
    }
    
    private func deleteOrderFromActiveRun(at offsets: IndexSet) {
        appStore.activeOrders.remove(atOffsets: offsets)
        if !appStore.activeOrderNames.contains(appStore.currentRunner) {
            appStore.currentRunner = ""
        }
    }
}
