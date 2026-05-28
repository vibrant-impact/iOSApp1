//
//  AddOrderView.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-21.
//

import SwiftUI
import Combine

struct AddOrderView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var appStore: OrderStore
        
    // Target pointer for edit context evaluations
    var editingOrder: TeamOrder?

    // Input State Parameters
    @State private var personName = ""
    @State private var selectedDrink = "Brewed Coffee"
    @State private var drinkQty = 1
    @State private var drinkNotes = ""
    @State private var drinkPrice = 1.83
    
    @State private var selectedFood = "None"
    @State private var foodQty = 1
    @State private var foodNotes = ""
    @State private var foodPrice = 0.0
        
    // Search terms inputs
    @State private var drinkSearchQuery = ""
    @State private var foodSearchQuery = ""
    @State private var saveAsFavorite = false
    
    // Dynamic Filtering Closures
    var searchedDrinksList: [JSONProduct] {
        let items = appStore.allProducts.filter { $0.category.lowercased().contains("drink") || $0.category.lowercased().contains("coffee") || $0.category.lowercased().contains("tea") }
        if drinkSearchQuery.isEmpty { return items }
        return items.filter { $0.name.lowercased().contains(drinkSearchQuery.lowercased()) }
    }
        
    var searchedFoodList: [JSONProduct] {
        let items = appStore.allProducts.filter { !$0.category.lowercased().contains("drink") && !$0.category.lowercased().contains("coffee") && !$0.category.lowercased().contains("tea") }
        if foodSearchQuery.isEmpty { return items }
        return items.filter { $0.name.lowercased().contains(foodSearchQuery.lowercased()) }
    }

    // Custom Init Routine
    init(appStore: OrderStore, orderToEdit: TeamOrder? = nil) {
        self.appStore = appStore
        self.editingOrder = orderToEdit
                
        if let order = orderToEdit {
            _personName = State(initialValue: order.name)
            _selectedDrink = State(initialValue: order.drink.itemName)
            _drinkQty = State(initialValue: order.drink.quantity)
            _drinkNotes = State(initialValue: order.drink.notes)
            _drinkPrice = State(initialValue: order.drink.unitPrice)
            _selectedFood = State(initialValue: order.food.itemName)
            _foodQty = State(initialValue: order.food.quantity)
            _foodNotes = State(initialValue: order.food.notes)
            _foodPrice = State(initialValue: order.food.unitPrice)
            _saveAsFavorite = State(initialValue: order.isSavedAsFavorite)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Quick-Load Favorites Section
                if editingOrder == nil && !appStore.savedFavorites.isEmpty {
                    Section(header: Text("🌟 Quick Load Favorite")) {
                        Menu("Tap to choose a profile...") {
                            ForEach(appStore.savedFavorites) { favorite in
                                Button(favorite.name) {
                                    personName = favorite.name
                                    selectedDrink = favorite.drink.itemName
                                    drinkQty = favorite.drink.quantity
                                    drinkNotes = favorite.drink.notes
                                    drinkPrice = favorite.drink.unitPrice
                                    selectedFood = favorite.food.itemName
                                    foodQty = favorite.food.quantity
                                    foodNotes = favorite.food.notes
                                    foodPrice = favorite.food.unitPrice
                                    saveAsFavorite = true
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Profile Identity")) {
                    TextField("Enter Name", text: $personName)
                        .disabled(editingOrder != nil)
                }
                
                // SEARCHABLE DRINK PICKER SECTION
                Section(header: Text("☕ Search and Select Drink")) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Type to search drinks...", text: $drinkSearchQuery)
                }
                    
                    Picker("Drink Selection", selection: $selectedDrink) {
                        ForEach(searchedDrinksList, id: \.name) { product in
                        Text("\(product.name) ($\(String(format: "%.2f", product.price)))")
                            .tag(product.name)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    // Sync item price instantly when menu row selection changes
                    .onChange(of: selectedDrink) { oldVal, newVal in
                        if let matched = appStore.allProducts.first(where: { $0.name == newVal }) {
                            drinkPrice = matched.price
                        }
                    }
                                            
                    Stepper("Quantity: \(drinkQty)", value: $drinkQty, in: 1...10)
                    TextField("Notes (e.g., extra ice, almond milk)", text: $drinkNotes)
                }
                                    
                // SEARCHABLE FOOD PICKER SECTION
                Section(header: Text("🍩 Search and Select Food")) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Type to search food...", text: $foodSearchQuery)
                    }
                    
                    Picker("Food Selection", selection: $selectedFood) {
                        Text("None").tag("None")
                        ForEach(searchedFoodList, id: \.name) { product in
                            Text("\(product.name) ($\(String(format: "%.2f", product.price)))")
                                .tag(product.name)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .onChange(of: selectedFood) { oldVal, newVal in
                        if newVal == "None" {
                            foodPrice = 0.0
                        } else if let matched = appStore.allProducts.first(where: { $0.name == newVal }) {
                            foodPrice = matched.price
                        }
                    }
                                                
                    if selectedFood != "None" {
                        Stepper("Quantity: \(foodQty)", value: $foodQty, in: 1...10)
                        TextField("Notes (e.g., heated up, extra napkins)", text: $foodNotes)
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
                        let createdOrder = TeamOrder(
                            name: personName.isEmpty ? "Guest" : personName,
                            drink: OrderItem(itemName: selectedDrink, quantity: drinkQty, notes: drinkNotes, unitPrice: drinkPrice),
                            food: OrderItem(itemName: selectedFood, quantity: foodQty, notes: foodNotes, unitPrice: foodPrice),
                                                        isSavedAsFavorite: saveAsFavorite
                        )
                                                    
                        if let original = editingOrder,
                            let index = appStore.activeOrders.firstIndex(where: { $0.id == original.id }) {
                            appStore.activeOrders[index] = createdOrder
                        } else {
                            appStore.saveOrderToActiveRun(createdOrder)
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
