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
    var editingOrder: TeamOrder?
    
    // MARK: - Input State Management Properties
    @State private var personName = ""
    @State private var globalSearchQuery = ""
    @State private var itemNotes = ""
    @State private var itemQuantity = 1
    @State private var saveAsFavorite = false
    
    // Staging references tracking our chosen active item selection state parameters
    @State private var temporarySelectedItem: JSONProduct?
    
    // MARK: - Menu Tab State Anchors
    @State private var selectedMainMenuTab = "Hot Drinks"
    @State private var selectedSubMenuTab = "All"
    
    // MARK: - Structural Menu Configuration Mappings
    // Links your Main Menu text strings straight to beautiful, instructive SF Symbol icons
    let mainMenuCategories = [
        ("Hot Drinks", "cup.and.saucer.fill"),
        ("Cold Drinks", "snowflake"),
        ("Baked Goods", "birthday.cake.fill"),
        ("Lunch and Dinner", "fork.knife"),
        ("Merchandise", "bag.fill"),
        ("Tims at Home", "house.fill")
    ]
    
    /// Dynamically computes submenus strictly based on which Main Menu category tab is active
    var structuralSubMenusList: [String] {
        switch selectedMainMenuTab {
        case "Hot Drinks":
            return ["All", "Brewed Coffee", "Espresso Drinks", "Tea", "Hot Chocoloate"]
        case "Cold Drinks":
            return ["All", "Iced Coffee", "Iced Capp", "Cold Brew", "Iced Lattes", "Fruit Quenchers", "Frozen Lemonade", "Fountain Pop", "Bottled Drinks"]
        case "Lunch and Dinner":
            return ["All", "Flatbread Pizzas", "Wraps", "Sandwiches", "Bowls", "Potato Wedges"]
        case "Baked Goods":
            return ["All", "Donuts", "Timbits", "Bagels", "Muffins", "Cookies"]
        default:
            return ["All"]
        }
    }
    
    // MARK: - UNIVERSAL ADVANCED SEARCH FILTER
    /// Filters product items dynamically using name, main category tabs, submenus, AND universal category searches simultaneously
    var filteredProductsManifestList: [JSONProduct] {
        appStore.allProducts.filter { product in
            
            // 1. Core search text matching logic (checks item title AND category fields concurrently)
            let matchesSearchText = globalSearchQuery.isEmpty ? true : (
                product.name.lowercased().contains(globalSearchQuery.lowercased()) ||
                product.category.lowercased().contains(globalSearchQuery.lowercased())
            )
            
            // 2. Main menu tab matching logic
            let matchesMainMenu = product.category.lowercased().contains(selectedMainMenuTab.lowercased())
            
            // 3. Submenu tab matching logic
            let matchesSubMenu = selectedSubMenuTab == "All" ? true : product.category.lowercased().contains(selectedSubMenuTab.lowercased())
            
            // Combine all constraints together
            return matchesSearchText && matchesMainMenu && matchesSubMenu
        }
    }
    
    // Grid column configuration setup to ensure neat, dual-card alignments
    let cardGridLayoutColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    // MARK: - Custom Init Routine
    init(appStore: OrderStore, orderToEdit: TeamOrder? = nil) {
        self.appStore = appStore
        self.editingOrder = orderToEdit
        
        if let order = orderToEdit {
            _personName = State(initialValue: order.name)
            _itemNotes = State(initialValue: order.drink.notes)
            _itemQuantity = State(initialValue: order.drink.quantity)
            
            if let matchedProduct = appStore.allProducts.first(where: { $0.name == order.drink.itemName }) {
                _temporarySelectedItem = State(initialValue: matchedProduct)
            }
            _saveAsFavorite = State(initialValue: order.isSavedAsFavorite)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Identity Input Profile Header Panel
                VStack(alignment: .leading, spacing: 6) {
                    Text("WHO IS PLACING THIS ORDER?")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter Name (e.g., Alex, Sam)", text: $personName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .disabled(editingOrder != nil)
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Unified Search Input Bar Panel
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Type to search any item or category (e.g., 'Hot')...", text: $globalSearchQuery)
                        .autocorrectionDisabled()
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 14)
                
                // VISUAL MAIN MENU TAB PILLS (Grid Layout replacing horizontal scroll)
                VStack(alignment: .leading, spacing: 6) {
                    Text("MAIN CATEGORIES")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], spacing: 8) {
                        ForEach(mainMenuCategories, id: \.0) { categoryName, symbolIcon in
                            Button(action: {
                                selectedMainMenuTab = categoryName
                                selectedSubMenuTab = "All" // Auto-reset fallback submenu tab
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: symbolIcon)
                                        .font(.footnote)
                                    Text(categoryName)
                                        .font(.system(size: 11, weight: .bold))
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(selectedMainMenuTab == categoryName ? Color.timsRed : Color(.systemGray6))
                                .foregroundColor(selectedMainMenuTab == categoryName ? .white : .primary)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 12)
                
                // DYNAMIC SUB-MENU ACCORDION BAR
                if structuralSubMenusList.count > 1 {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("SUB-MENU SELECTIONS")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(structuralSubMenusList, id: \.self) { subName in
                                    Button(action: { selectedSubMenuTab = subName }) {
                                        Text(subName)
                                            .font(.system(size: 12, weight: .semibold))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 6)
                                            .background(selectedSubMenuTab == subName ? Color.black : Color(.systemGray6))
                                            .foregroundColor(selectedSubMenuTab == subName ? .white : .primary)
                                            .cornerRadius(14)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 12)
                }
                
                Divider()
                
                // PRODUCT GRID VIEW CANVAS
                ScrollView {
                    if filteredProductsManifestList.isEmpty {
                        VStack(spacing: 12) {
                            Spacer()
                            Image(systemName: "tray.search")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("No matching Tims menu items found.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.top, 40)
                    } else {
                        LazyVGrid(columns: cardGridLayoutColumns, spacing: 12) {
                            ForEach(filteredProductsManifestList) { product in
                                ProductCardView(product: product) {
                                    // Updates the active bottom control tray targets
                                    temporarySelectedItem = product
                                    itemQuantity = 1
                                }
                            }
                        }
                        .padding()
                    }
                }
                .background(Color(.systemGroupedBackground))
                
                // SELECTION CHECKOUT OVERLAY PANEL FOOTER LAYER
                if let selection = temporarySelectedItem {
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Selected Selection:")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text(selection.name)
                                    .font(.subheadline)
                                    .bold()
                                    .lineLimit(1)
                            }
                            Spacer()
                            
                            Stepper("Qty: \(itemQuantity)", value: $itemQuantity, in: 1...10)
                                .labelsHidden()
                            Text("\(itemQuantity)x")
                                .font(.subheadline)
                                .bold()
                        }
                        
                        TextField("Add customization notes (e.g., triple triple, extra hot)...", text: $itemNotes)
                            .padding(10)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .font(.footnote)
                        
                        HStack {
                            Toggle("Save as Favorite Profile", isOn: $saveAsFavorite)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button(action: {
                                // 1. Double check that we have a valid product selection before executing
                                guard let selection = temporarySelectedItem else { return }
                                
                                // 2. Compile the chosen item metadata into a robust OrderItem model struct
                                let chosenItem = OrderItem(
                                    itemName: selection.name,
                                    quantity: itemQuantity,
                                    notes: itemNotes,
                                    unitPrice: selection.price
                                )
                                
                                // 3. Assemble the complete TeamOrder payload wrapper
                                let packageOrder = TeamOrder(
                                    name: personName.isEmpty ? "Guest" : personName,
                                    drink: chosenItem, // Stores the selected product safely into the primary order line
                                    food: OrderItem(itemName: "None", quantity: 1, notes: "", unitPrice: 0.0),
                                    isSavedAsFavorite: saveAsFavorite
                                )
                                
                                // 4. Determine if we are updating an existing person or appending a brand new profile row
                                if let original = editingOrder,
                                   let index = appStore.activeOrders.firstIndex(where: { $0.id == original.id }) {
                                    appStore.activeOrders[index] = packageOrder
                                } else {
                                    // Appends cleanly as a separate entry row inside the global team array loop!
                                    appStore.saveOrderToActiveRun(packageOrder)
                                }
                                
                                // 5. Dismiss the modal to return cleanly to the updated main manifest summary screen
                                dismiss()
                            }) {
                                Text("Confirm Selection")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color.timsRed)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .transition(.move(edge: .bottom))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -4)
                }
            }
            .navigationTitle(editingOrder == nil ? "Build Order" : "Modify Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
