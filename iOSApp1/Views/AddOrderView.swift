//
//  AddOrderView.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-21.
//

import SwiftUI
import Combine

struct AddOrderView: View {
    // MARK: - View Environments
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
    @State private var pendingItems: [OrderItem] = []
    @State private var useDrinkCredit = false
    @State private var showingNameWarningAlert = false
    
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
            return ["All", "Brewed Coffee", "Espresso Drinks", "Tea", "Hot Chocolate"]
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
    
    var filteredProducts: [JSONProduct] {
        let query = globalSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // If search bar is completely empty, serve up the full product catalog list
        guard !query.isEmpty else { return appStore.allProducts }
        
        return appStore.allProducts.filter { product in
            let nameMatches = product.name.lowercased().contains(query)
                
            // Sweeps the product's category tags array to find any keyword matches
            let categoryMatches = product.category.lowercased().contains(query)
                
            // FIXED: Removed the stray closing brace so this returns inside the filter closure perfectly!
            return nameMatches || categoryMatches
        }
    }

    
    /// Finds the real-time credit balance of the typed profile instance name
    var userProfileCreditBalance: Int {
        let targetName = personName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !targetName.isEmpty else { return 0 }
        return appStore.userProfiles.first(where: { $0.name.lowercased() == targetName.lowercased() })?.drinkCreditsBalance ?? 0
    }
    
    /// Computes the final basket cost total, zeroing out the highest-priced item if the redemption toggle is active
    var computedBasketTotal: Double {
        let rawTotal = pendingItems.reduce(0) { $0 + $1.itemTotal }
        guard useDrinkCredit, !pendingItems.isEmpty else { return rawTotal }
        
        // Finds the maximum single unit price item inside the basket list array
        if let highestPricedItem = pendingItems.max(by: { $0.unitPrice < $1.unitPrice }) {
            return rawTotal - highestPricedItem.unitPrice
        }
        return rawTotal
    }
    
    var profileFavoriteMatchItems: [OrderItem]? {
        let targetName = personName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !targetName.isEmpty else { return nil }
        if let match = appStore.userProfiles.first(where: { $0.name.lowercased() == targetName.lowercased() }),
           !match.savedFavoriteItems.isEmpty {
            return match.savedFavoriteItems
        }
        return nil
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
            _pendingItems = State(initialValue: order.items)
            _saveAsFavorite = State(initialValue: order.isSavedAsFavorite)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    
                    // ==========================================
                    // 1. THE TOP AREA: Header Panel
                    // ==========================================
                    VStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("WHO IS PLACING THIS ORDER?")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundColor(.timsRed)
                            
                            
                            TextField("Enter Name (e.g., Alex, Stephanie)", text: $personName)
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(Color.timsDarkBrown)
                                .padding()
                                .background(Color.timsFieldTan)
                                .cornerRadius(12)
                                .disabled(editingOrder != nil)
                            
                            if let favoriteRoutine = profileFavoriteMatchItems, pendingItems.isEmpty {
                                Button(action: {
                                    SoundManager.shared.playSound(named: "ching", withExtension: "mp3")
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        pendingItems = favoriteRoutine
                                        saveAsFavorite = true
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.orange)
                                        Text("Auto-Load \(personName)'s Favorite Order ⭐️")
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                            .foregroundColor(.timsDarkBrown)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.orange.opacity(0.15))
                                    .cornerRadius(10)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 4)
                            }
                        }
                        .padding(.top, 10)
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color.timsDarkBrown)
                            TextField("Search names or categories (e.g., 'Chocolate')...", text: $globalSearchQuery)
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(Color.timsDarkBrown)
                                .autocorrectionDisabled()
                        }
                        .padding(14)
                        .background(Color.timsFieldTan)
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MAIN CATEGORIES")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundColor(.timsDarkBrown.opacity(0.7))
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], spacing: 8) {
                                ForEach(mainMenuCategories, id: \.0) { categoryName, symbolIcon in
                                    Button(action: {
                                        SoundManager.shared.playSound(named: "pop", withExtension: "mp3")
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            selectedMainMenuTab = categoryName
                                            selectedSubMenuTab = "All"
                                            temporarySelectedItem = nil
                                        }
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
                                        .background(selectedMainMenuTab == categoryName ? Color.orange : Color.timsFieldTan)
                                        .foregroundColor(selectedMainMenuTab == categoryName ? .timsDarkBrown : .timsDarkBrown)
                                        .cornerRadius(12)
                                        .contentShape(Rectangle())
                                        .shadow(color: selectedMainMenuTab == categoryName ? Color.orange.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 3)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        
                        if structuralSubMenusList.count > 1 {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(structuralSubMenusList, id: \.self) { subName in
                                        Button(action: {
                                            SoundManager.shared.playSound(named: "pop", withExtension: "mp3")
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                selectedSubMenuTab = subName
                                                temporarySelectedItem = nil
                                            }
                                        }) {
                                            Text(subName)
                                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(selectedSubMenuTab == subName ? Color.timsDarkBrown : Color.timsFieldTan)
                                                .foregroundColor(selectedSubMenuTab == subName ? Color.timsTan : .brown)
                                                .cornerRadius(30)
                                                .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                    .padding([.horizontal, .bottom])
                    .background(Color.timsTan)
                    .zIndex(1)
                    
                    // ==========================================
                    // 2. THE MAIN CANVAS AREA: Dynamic Scroll Catalog Grid
                    // ==========================================
                    ZStack {
                        Image("brownSwirlBackground")
                            .resizable()
                            .ignoresSafeArea()
                        
                        ScrollView {
                            LazyVGrid(columns: cardGridLayoutColumns, spacing: 14) {
                                ForEach(filteredProducts) { product in
                                    ProductCardView(product: product) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            temporarySelectedItem = product
                                            itemQuantity = 1
                                        }
                                    }
                                    .contentShape(Rectangle())
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                            // Adds dynamic scroll cushion so content never gets permanently hidden behind floating bars
                            .padding(.bottom, pendingItems.isEmpty ? 20 : 130)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                if temporarySelectedItem != nil {
                    Color.black.opacity(0.01)
                        .ignoresSafeArea()
                        .zIndex(2)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                temporarySelectedItem = nil
                            }
                        }
                }
                
                // ==========================================
                // 3. THE FLOATING FOOTER PANEL: Selection Checkout Drawer
                // ==========================================
                if let selection = temporarySelectedItem {
                    VStack {
                        Spacer()
                        
                        VStack(spacing: 14) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("ADD TO YOUR BASKET")
                                        .font(.system(size: 10, weight: .black, design: .rounded))
                                        .foregroundColor(.orange)
                                    Text(selection.name)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.timsDarkBrown)
                                        .lineLimit(1)
                                }
                                Spacer()
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        temporarySelectedItem = nil
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.brown.opacity(0.5))
                                }
                                .buttonStyle(.plain)
                            }
                            
                            HStack {
                                Text("$\(String(format: "%.2f", selection.price)) each")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.orange)
                                Spacer()
                                
                                HStack(spacing: 16) {
                                    Button(action: {
                                        if itemQuantity > 1 {
                                            itemQuantity -= 1
                                            SoundManager.shared.playSound(named: "click", withExtension: "mp3")
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(itemQuantity > 1 ? .timsRed : .brown.opacity(0.5))
                                    }
                                    Text("\(itemQuantity)")
                                        .font(.system(size: 18, weight: .black, design: .rounded))
                                        .foregroundColor(.timsDarkBrown)
                                        .frame(minWidth: 24)
                                    Button(action: {
                                        if itemQuantity < 10 {
                                            itemQuantity += 1
                                            SoundManager.shared.playSound(named: "click", withExtension: "mp3")
                                        }
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.timsRed)
                                    }
                                }
                            }
                            
                            TextField("Add customization notes (e.g., extra hot)...", text: $itemNotes)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.timsDarkBrown)
                                .padding(12)
                                .background(Color.timsFieldTan)
                                .cornerRadius(10)
                            
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    let nestedItem = OrderItem(itemName: selection.name, quantity: itemQuantity, notes: itemNotes, unitPrice: selection.price)
                                    SoundManager.shared.playSound(named: "pouring", withExtension: "mp3")
                                    
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        pendingItems.append(nestedItem)
                                        temporarySelectedItem = nil
                                        itemNotes = ""
                                        itemQuantity = 1
                                    }
                                }) {
                                    Text("Add to Basket")
                                        .font(.system(size: 15, weight: .black, design: .rounded))
                                        .foregroundColor(.timsDarkBrown)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 14)
                                        .background(Color.orange)
                                        .cornerRadius(14)
                                        .shadow(color: Color.orange.opacity(0.4), radius: 8, x: 0, y: 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                        .background(Color.timsTan)
                        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: -4)
                    }
                    .zIndex(4)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            // ==========================================
            // FIXED OVERLAY: Absolute Bottom Safe Area Pinning with Reward Redemption
            // ==========================================
            .overlay(alignment: .bottom) {
                if !pendingItems.isEmpty && temporarySelectedItem == nil {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("\(personName.isEmpty ? "Guest" : personName)'s Basket (\(pendingItems.reduce(0) { $0 + $1.quantity }) items)")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundColor(.timsDarkBrown)
                            Spacer()
                            Text("$\(String(format: "%.2f", computedBasketTotal))")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundColor(.timsRed)
                        }
                        
                        Toggle(isOn: $saveAsFavorite) {
                            Label("Save this complete order as Favorite", systemImage: "star.fill")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .orange))
                        // If the account profile has any free drink tokens, expose a redemption control row slider
                        if userProfileCreditBalance > 0 {
                            Toggle(isOn: $useDrinkCredit) {
                                Label("Apply Free Drink Credit (Available: \(userProfileCreditBalance)) 🌟", systemImage: "ticket.fill")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.green)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                            .padding(.top, 2)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                        
                        Button(action: {
                            // Checks if the user actually typed a name. If blank, show the warning instead of submitting!
                            let cleanedName = personName.trimmingCharacters(in: .whitespacesAndNewlines)
                            if cleanedName.isEmpty {
                                SoundManager.shared.playSound(named: "buzzer", withExtension: "mp3")
                                    showingNameWarningAlert = true
                            } else {
                                SoundManager.shared.playSound(named: "success", withExtension: "mp3")
                                
                                // Automatically locates the user's profile and subtracts a credit token if applied
                                if useDrinkCredit, let index = appStore.userProfiles.firstIndex(where: { $0.name.lowercased() == personName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }) {
                                    if appStore.userProfiles[index].drinkCreditsBalance > 0 {
                                        appStore.userProfiles[index].drinkCreditsBalance -= 1
                                    }
                                }
                                
                                let finalGroupOrder = TeamOrder(
                                    name: personName.isEmpty ? "Guest" : personName,
                                    items: pendingItems,
                                    isSavedAsFavorite: saveAsFavorite
                                )
                                
                                // Writes the profile information to local disk persistence states
                                if saveAsFavorite {
                                    appStore.saveFavoriteBasket(for: personName, items: pendingItems)
                                }
                                
                                if let original = editingOrder,
                                   let index = appStore.activeOrders.firstIndex(where: { $0.id == original.id }) {
                                    appStore.activeOrders[index] = finalGroupOrder
                                } else {
                                    appStore.saveOrderToActiveRun(finalGroupOrder)
                                }
                                dismiss()
                            }
                        }) {
                            Label("Complete Individual Order", systemImage: "checkmark.circle.fill")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundColor(.timsDarkBrown)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(personName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.timsGold.opacity(0.5) : Color.timsGold)
                                .cornerRadius(12)
                                .shadow(color: Color.orange.opacity(0.4), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                        .alert("Name Required", isPresented: $showingNameWarningAlert) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            Text("Please enter a name for who is placing this order before completing it.")
                        }
                        // Prevents creating accidental blank accounts
                        .disabled(personName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && pendingItems.isEmpty)
                        .opacity(personName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                    }
                    .padding([.horizontal, .top], 16)
                    .padding(.bottom, 34) // Flows cleanly into the virtual home indicator space
                    .background(Color.timsTan)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -4)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(3)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Custom large, orange typography
                ToolbarItem(placement: .principal) {
                    Text(editingOrder == nil ? "Build Order" : "Modify Order")
                        .font(.system(size: 36, weight: .black, design: .rounded)) // Made larger and bolder
                        .foregroundColor(.orange) // Swapped to your new custom orange accent
                }
                            
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.timsRed)
                }
            }
            .preferredColorScheme(.light)
            .presentationBackground(Color.timsTan)
        }
    }
}
