//
//  ManifestBuilderView.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-28.
//

import SwiftUI

struct ManifestBuilderView: View {
    @ObservedObject var appStore: OrderStore
    
    @Binding var runSequenceStarted: Bool
    @Binding var runTimerActive: Bool
    @Binding var isManifestLocked: Bool
    @Binding var selectedOrderToEdit: TeamOrder?
    @Binding var showingAddOrderForm: Bool
    
    var runningGrandTotal: Double {
        appStore.activeOrders.reduce(0) { $0 + $1.checkoutTotal }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Layer using your custom asset texture
                Image("brownSwirlBackground")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    // Custom Header Top Navigation Bar Component for distinct styling
                    HStack {
                        Button(action: { runSequenceStarted = false }) {
                            Text("Cancel Run")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                        }
                        
                        Spacer()
                        
                        Text("Add Orders")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        // Invisible structural balancer block to center the title perfectly
                        Text("Cancel Run").font(.system(size: 14)).opacity(0).padding(.horizontal, 14)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    List {
                        Section(header: Text(isManifestLocked ? "Current Group Orders" : "Current Group Orders (Tap to Edit)")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(.white.opacity(0.9)) // Prominent high contrast styling
                        ) {
                            if appStore.activeOrders.isEmpty {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 8) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.timsRed)
                                        Text("No orders added yet.\nTap 'Add Order' below to begin.")
                                            .font(.system(.subheadline, design: .rounded))
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary) // Dark crisp text inside the light card row
                                            .multilineTextAlignment(.center)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .listRowBackground(Color.white.opacity(0.92))
                            } else {
                                ForEach(appStore.activeOrders) { order in
                                    Button(action: {
                                        if !isManifestLocked {
                                            selectedOrderToEdit = order
                                            showingAddOrderForm = true
                                        }
                                    }) {
                                        HStack {
                                            // FIXED: Changed 'appleAlignment' to the correct standard 'alignment' parameter
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(order.name)
                                                    .font(.system(.headline, design: .rounded))
                                                    .foregroundColor(.primary)
                                                
                                                Text("☕ \(order.drink.quantity)x \(order.drink.itemName)")
                                                    .font(.system(.subheadline, design: .rounded))
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Text("$\(String(format: "%.2f", order.checkoutTotal))")
                                                .font(.system(.subheadline, design: .rounded))
                                                .fontWeight(.black)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                }
                                .onDelete(perform: deleteOrderFromActiveRun)
                                .listRowBackground(Color.white.opacity(0.92))
                            }
                        }
                        
                        if !appStore.activeOrders.isEmpty {
                            Section(header: Text("💰 Manifest Cost Summary")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))) {
                                HStack {
                                    Text("Estimated Total:")
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text("$\(String(format: "%.2f", runningGrandTotal))")
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.black)
                                        .foregroundColor(.green)
                                }
                            }
                            .listRowBackground(Color.white.opacity(0.92))
                        }
                        
                        if isManifestLocked {
                            Section(header: Text("📋 Select the Designated Runner")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))) {
                                Picker("Who is driving?", selection: $appStore.currentRunner) {
                                    Text("Choose Runner...").tag("")
                                    ForEach(appStore.activeOrderNames, id: \.self) { name in
                                        Text(name).tag(name)
                                    }
                                }
                                .font(.system(.body, design: .rounded))
                                .pickerStyle(.menu)
                            }
                            .listRowBackground(Color.white.opacity(0.92))
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.insetGrouped)
                    
                    // ==========================================
                    // ACTION CONTROL TRAY: HIGH POPPING BUTTON DESIGNS
                    // ==========================================
                    VStack(spacing: 12) {
                        if !isManifestLocked {
                            HStack(spacing: 16) {
                                Button(action: {
                                    selectedOrderToEdit = nil
                                    showingAddOrderForm = true
                                }) {
                                    Label("Add Order", systemImage: "plus.circle.fill")
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                        .foregroundColor(.timsRed)
                                        .padding(.vertical, 14)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .cornerRadius(14)
                                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                                }
                                
                                Button(action: { isManifestLocked = true }) {
                                    Text("Ready to Run!")
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 14)
                                        .frame(maxWidth: .infinity)
                                        .background(appStore.activeOrders.isEmpty ? Color.white.opacity(0.2) : Color.green)
                                        .cornerRadius(14)
                                        .shadow(color: appStore.activeOrders.isEmpty ? Color.clear : Color.green.opacity(0.4), radius: 8, x: 0, y: 4)
                                }
                                .disabled(appStore.activeOrders.isEmpty)
                            }
                        } else {
                            HStack(spacing: 16) {
                                Button(action: { isManifestLocked = false }) {
                                    Text("Unlock & Edit")
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 14)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white.opacity(0.25))
                                        .cornerRadius(14)
                                }
                                
                                Button(action: { runTimerActive = true }) {
                                    Text("🚀 Start Clock")
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 14)
                                        .frame(maxWidth: .infinity)
                                        .background(appStore.currentRunner.isEmpty ? Color.white.opacity(0.2) : Color.green)
                                        .cornerRadius(14)
                                        .shadow(color: appStore.currentRunner.isEmpty ? Color.clear : Color.green.opacity(0.4), radius: 8, x: 0, y: 4)
                                }
                                .disabled(appStore.currentRunner.isEmpty)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    .background(.ultraThinMaterial)
                }
            }
            .toolbar(.hidden, for: .navigationBar) // Intentionally hides system bar to use custom header component above
            .preferredColorScheme(.dark)
            // FIXED: Restored the essential modal sheet binding so the Add Order presentation context triggers correctly
            .sheet(isPresented: $showingAddOrderForm) {
                AddOrderView(appStore: appStore, orderToEdit: selectedOrderToEdit)
            }
            .preferredColorScheme(.dark)
        }
    }
    
    private func deleteOrderFromActiveRun(at offsets: IndexSet) {
        appStore.activeOrders.remove(atOffsets: offsets)
        if !appStore.activeOrderNames.contains(appStore.currentRunner) {
            appStore.currentRunner = ""
        }
    }
}
