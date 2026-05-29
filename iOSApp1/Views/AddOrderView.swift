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
    @State private var temporarySelectedItem: JSONProduct?
    
    // MARK: - Menu Tab State Anchors
    @State private var selectedMainMenuTab = "Hot Drinks"
    @State private var selectedSubMenuTab = "All"
    
    let mainMenuCategories = [
        ("Hot Drinks", "cup.and.saucer.fill"),
        ("Cold Drinks", "snowflake"),
        ("Baked Goods", "birthday.cake.fill"),
        ("Lunch and Dinner", "fork.knife"),
        ("Merchandise", "bag.fill"),
        ("Tims at Home", "house.fill")
    ]
    
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
    
    var filteredProductsManifestList: [JSONProduct] {
        appStore.allProducts.filter { product in
            let matchesSearchText = globalSearchQuery.isEmpty ? true : (
                product.name.lowercased().contains(globalSearchQuery.lowercased()) ||
                product.category.lowercased().contains(globalSearchQuery.lowercased())
            )
            let matchesMainMenu = product.category.lowercased().contains(selectedMainMenuTab.lowercased())
            let matchesSubMenu = selectedSubMenuTab == "All" ? true : product.category.lowercased().contains(selectedSubMenuTab.lowercased())
            return matchesSearchText && matchesMainMenu && matchesSubMenu
        }
    }
    
    let cardGridLayoutColumns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
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
                
                // ==========================================
                // 1. THE TOP AREA: Pure Solid White & Clean Contrast
                // ==========================================
                VStack(spacing: 14) {
                    // Custom Header Navigation Title Replacement to bypass sheet style overrides
                    HStack {
                        Button(action: { dismiss() }) {
                            Text("Close")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.timsRed)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.timsRed.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        Spacer()
                        
                        Text(editingOrder == nil ? "Build Order" : "Modify Order")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        // Invisible alignment spacer block
                        Text("Close").font(.system(size: 16)).opacity(0).padding(.horizontal, 16)
                    }
                    .padding(.top, 12)
                    
                    // Identity input textfield
                    VStack(alignment: .leading, spacing: 6) {
                        Text("WHO IS PLACING THIS ORDER?")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        TextField("Enter Name (e.g., Alex, Stephanie)", text: $personName)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.primary)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .disabled(editingOrder != nil)
                    }
                    
                    // Search Entry Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.timsRed)
                        TextField("Search names or categories (e.g., 'Churro')...", text: $globalSearchQuery)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.primary)
                            .autocorrectionDisabled()
                    }
                    .padding(14)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Main Categories Navigation Switcher
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MAIN CATEGORIES")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], spacing: 8) {
                            ForEach(mainMenuCategories, id: \.0) { categoryName, symbolIcon in
                                Button(action: {
                                    selectedMainMenuTab = categoryName
                                    selectedSubMenuTab = "All"
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: symbolIcon)
                                            .font(.system(size: 12, weight: .bold))
                                        Text(categoryName)
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(selectedMainMenuTab == categoryName ? Color.timsRed : Color(.systemGray5))
                                    .foregroundColor(selectedMainMenuTab == categoryName ? .white : .primary)
                                    .cornerRadius(12)
                                    .shadow(color: selectedMainMenuTab == categoryName ? Color.timsRed.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 3)
                                }
                            }
                        }
                    }
                    
                    // Horizontal Subcategories Sub-tabs
                    if structuralSubMenusList.count > 1 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(structuralSubMenusList, id: \.self) { subName in
                                    Button(action: { selectedSubMenuTab = subName }) {
                                        Text(subName)
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(selectedSubMenuTab == subName ? Color.primary : Color(.systemGray6))
                                            .foregroundColor(selectedSubMenuTab == subName ? Color(.systemBackground) : .secondary)
                                            .cornerRadius(30)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding([.horizontal, .bottom])
                .background(Color.white) // Strictly forces this section to remain white regardless of system traits
                
                // ==========================================
                // 2. THE GRID AREA: Deep Swirl Image Canvas Background
                // ==========================================
                ZStack {
                    Image("brownSwirlBackground")
                        .resizable()
                        .ignoresSafeArea()
                    
                    ScrollView {
                        if filteredProductsManifestList.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "tray.search")
                                    .font(.system(size: 44, weight: .light))
                                    .foregroundColor(.white.opacity(0.6))
                                Text("No matching Tims menu items found.")
                                    .font(.system(.headline, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.top, 80)
                        } else {
                            LazyVGrid(columns: cardGridLayoutColumns, spacing: 14) {
                                ForEach(filteredProductsManifestList) { product in
                                    ProductCardView(product: product) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            temporarySelectedItem = product
                                            itemQuantity = 1
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                        }
                    }
                }
                
                // ==========================================
                // 3. THE FOOTER PANEL: Floating Bottom Dock
                // ==========================================
                if let selection = temporarySelectedItem {
                    VStack(spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SELECTED MENU ITEM")
                                    .font(.system(size: 10, weight: .black, design: .rounded))
                                    .foregroundColor(.secondary)
                                Text(selection.name)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            
                            HStack(spacing: 16) {
                                Button(action: { if itemQuantity > 1 { itemQuantity -= 1 } }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(itemQuantity > 1 ? .timsRed : .gray.opacity(0.3))
                                }
                                Text("\(itemQuantity)")
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                                    .foregroundColor(.primary)
                                    .frame(minWidth: 24)
                                Button(action: { if itemQuantity < 10 { itemQuantity += 1 } }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.timsRed)
                                }
                            }
                        }
                        
                        TextField("Add customization notes (e.g., extra hot)...", text: $itemNotes)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.primary)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        HStack {
                            Toggle(isOn: $saveAsFavorite) {
                                Label("Save Profile", systemImage: "star.fill")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.orange)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .orange))
                            
                            Spacer(minLength: 20)
                            
                            Button(action: {
                                let chosenItem = OrderItem(itemName: selection.name, quantity: itemQuantity, notes: itemNotes, unitPrice: selection.price)
                                let packageOrder = TeamOrder(
                                    name: personName.isEmpty ? "Guest" : personName,
                                    drink: chosenItem,
                                    food: OrderItem(itemName: "None", quantity: 1, notes: "", unitPrice: 0.0),
                                    isSavedAsFavorite: saveAsFavorite
                                )
                                
                                if let original = editingOrder,
                                   let index = appStore.activeOrders.firstIndex(where: { $0.id == original.id }) {
                                    appStore.activeOrders[index] = packageOrder
                                } else {
                                    appStore.saveOrderToActiveRun(packageOrder)
                                }
                                dismiss()
                            }) {
                                Text("Add to Manifest")
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 14)
                                    .background(Color.timsRed)
                                    .cornerRadius(14)
                                    .shadow(color: Color.timsRed.opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: -4)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .toolbar(.hidden, for: .navigationBar) // Employs our customized clean top banner instead
            .preferredColorScheme(.light) // Fixes internal asset components to remain bright
        }
    }
}
