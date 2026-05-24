//
//  AddOrderView.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-23.
//

import SwiftUI
import Combine

struct AddOrderView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var appStore: OrderStore
    
    // Check if we are editing an existing order
    var editingOrder: TeamOrder?
    
    // Form Input States
    @State private var personName = ""
    @State private var selectedDrink = "Double Double"
    @State private var drinkQty = 1
    @State private var drinkNotes = ""
    
    @State private var selectedFood = "None"
    @State private var foodQty = 1
    @State private var foodNotes = ""
    
    @State private var saveAsFavorite = false
    
    // Run an initializer to pre-fill the form if we are editing an order
    init(appStore: OrderStore, orderToEdit: TeamOrder? = nil) {
        self.appStore = appStore
        self.editingOrder = orderToEdit
        
        // If an order was passed in for editing, set the initial states to its values
        if let order = orderToEdit {
            _personName = State(initialValue: order.name)
            _selectedDrink = State(initialValue: order.drink.itemName)
            _drinkQty = State(initialValue: order.drink.quantity)
            _drinkNotes = State(initialValue: order.drink.notes)
            _selectedFood = State(initialValue: order.food.itemName)
            _foodQty = State(initialValue: order.food.quantity)
            _foodNotes = State(initialValue: order.food.notes)
            _saveAsFavorite = State(initialValue: order.isSavedAsFavorite)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Quick Load Favorites (Only show if we aren't currently editing an existing item)
                if editingOrder == nil && !appStore.savedFavorites.isEmpty {
                    Section(header: Text("🌟 Quick Load Favorite")) {
                        Menu("Tap to choose a favorite profile...") {
                            ForEach(appStore.savedFavorites) { favorite in
                                Button(favorite.name) {
                                    personName = favorite.name
                                    selectedDrink = favorite.drink.itemName
                                    drinkQty = favorite.drink.quantity
                                    drinkNotes = favorite.drink.notes
                                    selectedFood = favorite.food.itemName
                                    foodQty = favorite.food.quantity
                                    foodNotes = favorite.food.notes
                                    saveAsFavorite = true
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Who is ordering?")) {
                    TextField("Enter Name", text: $personName)
                        .disabled(editingOrder != nil) // Keep name locked if editing
                }
                
                Section(header: Text("☕ Drink Selection")) {
                    // Changing to navigationLink style
                    Picker("Drink Type", selection: $selectedDrink) {
                        ForEach(appStore.drinkOptions, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.navigationLink)
                    
                    Stepper("Quantity: \(drinkQty)", value: $drinkQty, in: 1...10)
                    TextField("Notes (e.g., extra ice, oat milk)", text: $drinkNotes)
                }
                
                Section(header: Text("🍩 Food & Snacks")) {
                    Picker("Food Item", selection: $selectedFood) {
                        ForEach(appStore.foodOptions, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.navigationLink)
                    
                    if selectedFood != "None" {
                        Stepper("Quantity: \(foodQty)", value: $foodQty, in: 1...10)
                        TextField("Notes (e.g., toasted twice)", text: $foodNotes)
                    }
                }
                
                Section(header: Text("Preferences")) {
                    Toggle("Save/Update as Favorite Profile", isOn: $saveAsFavorite)
                }
            }
            .navigationTitle(editingOrder == nil ? "Add Order" : "Edit Order")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        let updatedOrder = TeamOrder(
                            name: personName.isEmpty ? "Guest" : personName,
                            drink: OrderItem(itemName: selectedDrink, quantity: drinkQty, notes: drinkNotes),
                            food: OrderItem(itemName: selectedFood, quantity: foodQty, notes: foodNotes),
                            isSavedAsFavorite: saveAsFavorite
                        )
                        
                        if let original = editingOrder,
                           let index = appStore.activeOrders.firstIndex(where: { $0.id == original.id }) {
                            // Replace the old order data with our updated edits
                            appStore.activeOrders[index] = updatedOrder
                        } else {
                            // Otherwise, save as a brand new entry
                            appStore.saveOrderToActiveRun(updatedOrder)
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
