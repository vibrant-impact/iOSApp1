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
            VStack {
                List {
                    Section(header: Text(isManifestLocked ? "Current Group Orders" : "Current Group Orders (Tap to Edit)")) {
                        if appStore.activeOrders.isEmpty {
                            Text("No orders added yet. Tap '+' below to begin.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
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
                                            Text(order.name).font(.headline)
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
                                    }
                                }
                            }
                            .onDelete(perform: deleteOrderFromActiveRun)
                        }
                    }
                    
                    if !appStore.activeOrders.isEmpty {
                        Section(header: Text("💰 Total for All Orders")) {
                            HStack {
                                Text("Estimated Run Total:")
                                    .fontWeight(.bold)
                                Spacer()
                                Text("$\(String(format: "%.2f", runningGrandTotal))")
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    if isManifestLocked {
                        Section(header: Text("📋 Select the Designated Runner")) {
                            Picker("Who is driving?", selection: $appStore.currentRunner) {
                                Text("Choose Runner...").tag("")
                                ForEach(appStore.activeOrderNames, id: \.self) { name in
                                    Text(name).tag(name)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                
                // Action Control Tray Base Footer Buttons
                VStack(spacing: 12) {
                    if !isManifestLocked {
                        HStack(spacing: 16) {
                            // Trigger button to load or construct a brand new individual item sheet modal
                            Button(action: {
                                selectedOrderToEdit = nil
                                showingAddOrderForm = true
                            }) {
                                Label("Add Order", systemImage: "plus")
                                    .font(.headline)
                                    .foregroundColor(.timsRed)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.timsRed.opacity(0.1))
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
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemGray5))
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
            }
            .navigationTitle("Add Orders")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel Setup") { runSequenceStarted = false }
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
