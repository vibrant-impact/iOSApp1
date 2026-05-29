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
                
                VStack(spacing: 0) {
                    
                    // ==========================================
                    // NEW PREMIUM HEADER: Split Controls & Titles
                    // ==========================================
                    VStack(alignment: .leading, spacing: 12) {
                        // Top Utility Row (Dismiss Button Only)
                        HStack {
                            Button(action: { runSequenceStarted = false }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                    Text("Cancel Run")
                                }
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(10)
                            }
                            
                            Spacer() // Pushes button all the way left
                        }
                        
                        // Bold Large Feature Title Stacking Layer
                        Text("Add Orders")
                            .font(.system(size: 36, weight: .black, design: .rounded)) // Massive feature scale
                            .foregroundColor(.timsGold) // Brand new popping asset color!
                            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 14)
                    .padding(.bottom, 10)
                    
                    // ==========================================
                    // MAIN MANIFEST ROW LIST (Stays exactly the same)
                    // ==========================================
                    List {
                        Section(header: Text(isManifestLocked ? "Current Group Orders" : "Current Group Orders (Tap to Edit)")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
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
                                            .foregroundColor(.brown)
                                            .multilineTextAlignment(.center)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .listRowBackground(Color.timsTan.opacity(0.92))
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
                                .listRowBackground(Color.timsTan.opacity(0.92))
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
                            .listRowBackground(Color.timsTan.opacity(0.92))
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
                            .listRowBackground(Color.timsTan.opacity(0.92))
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.insetGrouped)
                    
                    // ==========================================
                    // ACTION CONTROL TRAY (Stays exactly the same)
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
                                        .foregroundColor(.timsDarkBrown)
                                        .padding(.vertical, 14)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.timsGold)
                                        .cornerRadius(14)
                                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                                }
                                
                                Button(action: { isManifestLocked = true }) {
                                    Text("Ready to Run!")
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                        .foregroundColor(.timsDarkBrown)
                                        .padding(.vertical, 14)
                                        .frame(maxWidth: .infinity)
                                        .background(appStore.activeOrders.isEmpty ? Color.timsTan : Color.red)
                                        .cornerRadius(14)
                                        .shadow(color: appStore.activeOrders.isEmpty ? Color.clear : Color.red.opacity(0.4), radius: 8, x: 0, y: 4)
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
                                        .background(Color.timsTan)
                                        .cornerRadius(14)
                                }
                                
                                Button(action: { runTimerActive = true }) {
                                    Text("🚀 Start Clock")
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 14)
                                        .frame(maxWidth: .infinity)
                                        .background(appStore.currentRunner.isEmpty ? Color.timsTan : Color.red)
                                        .cornerRadius(14)
                                        .shadow(color: appStore.currentRunner.isEmpty ? Color.clear : Color.red.opacity(0.4), radius: 8, x: 0, y: 4)
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
            .toolbar(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showingAddOrderForm) {
                AddOrderView(appStore: appStore, orderToEdit: selectedOrderToEdit)
            }
        }
    }
                        
    // MARK: - Swiping Action Logic
    /// Deletes a specific user order row item from the active group run manifest
    private func deleteOrderFromActiveRun(at offsets: IndexSet) {
        appStore.activeOrders.remove(atOffsets: offsets)
                            
        // Safety check: If the person driving was just deleted, reset the selection picker context
        if !appStore.activeOrderNames.contains(appStore.currentRunner) {
            appStore.currentRunner = ""
        }
    }
}
