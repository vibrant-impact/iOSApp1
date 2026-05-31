//
//  AddOrderView.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-21.
//

import SwiftUI
import Combine

struct AddOrderView: View {
    // View environments handling sheet removal behaviors
    @Environment(\.dismiss) var dismiss
    @ObservedObject var appStore: OrderStore
    var editingOrder: TeamOrder?
    
    // Input state management properties tracking user text entries and menu choices
    @State private var personName = ""
    @State private var globalSearchQuery = ""
    @State private var itemNotes = ""
    @State private var itemQuantity = 1
    @State private var saveAsFavorite = false
    @State private var temporarySelectedItem: JSONProduct?
    @State private var pendingItems: [OrderItem] = []
    @State private var useDrinkCredit = false
    @State private var showingNameWarningAlert = false
    @State private var isShowingBasketSummary = false
    
    // Menu tab state anchors filtering the main product catalog collections
    @State private var selectedCategory: String? = nil
    @State private var selectedSubcategory: String? = nil
    
    let mainMenuCategories = [
        ("Hot Drinks", "cup.and.saucer.fill"),
        ("Cold Drinks", "snowflake"),
        ("Baked Goods", "birthday.cake.fill"),
        ("Breakfast", "spoon.serving"),
        ("Lunch & Dinner", "fork.knife"),
        ("Tims at Home", "house.fill")
    ]
    
    var structuralSubMenusList: [String] {
        switch selectedCategory {
        case "Hot Drinks":
            return ["Brewed Coffee", "Espresso Drinks", "Tea", "Hot Chocolate"]
        case "Cold Drinks":
            return ["Iced Coffee", "Iced Capp", "Cold Brew", "Iced Lattes", "Fruit Quenchers", "Frozen Lemonade", "Fountain Pop", "Bottled Drinks"]
        case "Baked Goods":
            return ["Donuts", "Timbits", "Bagels", "Muffins", "Cookies", "Croissants"]
        case "Breakfast":
            return ["Breakfast Sandwiches", "Breakdfast Wraps", "Hashbrown", "Omelette Bites"]
        case "Lunch & Dinner":
            return ["Flatbread Pizzas", "Wraps", "Sandwiches", "Bowls", "Soup & Chili", "Potato Wedges"]
        case "Tims at Home":
            return ["Tims at Home"]
        default:
            return ["All"]
        }
    }
    
    var filteredProducts: [JSONProduct] {
        let textQuery = globalSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        return appStore.allProducts.filter { product in
            if !textQuery.isEmpty {
                let nameMatches = product.name.lowercased().contains(textQuery)
                let categoryMatches = product.category.lowercased().contains(textQuery)
                guard nameMatches || categoryMatches else { return false }
            }
            if let mainCat = selectedCategory {
                guard product.category.lowercased().contains(mainCat.lowercased()) else { return false }
            }
            if let subCat = selectedSubcategory {
                guard product.category.lowercased().contains(subCat.lowercased()) else { return false }
            }
            return true
        }
    }

    var userProfileCreditBalance: Int {
        let targetName = personName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !targetName.isEmpty else { return 0 }
        return appStore.userProfiles.first(where: { $0.name.lowercased() == targetName.lowercased() })?.drinkCreditsBalance ?? 0
    }
    
    // Computes the final basket cost total, applying a max $6.00 credit to the most expensive beverage if active
    var computedBasketTotal: Double {
        let rawTotal = pendingItems.reduce(0) { $0 + $1.itemTotal }
        guard useDrinkCredit, !pendingItems.isEmpty else { return rawTotal }
        
        // Filters to find only beverage items, ignoring food or merchandise box items
        let beverages = pendingItems.filter { item in
            let name = item.itemName.lowercased()
            return name.contains("coffee") || name.contains("capp") || name.contains("latte") ||
                   name.contains("tea") || name.contains("quencher") || name.contains("drink") ||
                   name.contains("brew") || name.contains("lemonade") || name.contains("chocolate")
        }
        
        // Finds the single highest-priced beverage unit in the basket
        if let highestPricedBeverage = beverages.max(by: { $0.unitPrice < $1.unitPrice }) {
            // Caps the discount deduction at a maximum value of $6.00
            let discountAmount = min(highestPricedBeverage.unitPrice, 6.00)
            return max(0.0, rawTotal - discountAmount)
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
                    // Header Panel text entry fields
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
                                    let isMainActive = selectedCategory?.lowercased() == categoryName.lowercased()
                                    
                                    Button(action: {
                                        SoundManager.shared.playSound(named: "pop", withExtension: "mp3")
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            if isMainActive {
                                                selectedCategory = nil
                                                selectedSubcategory = nil
                                            } else {
                                                selectedCategory = categoryName
                                                selectedSubcategory = nil
                                            }
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
                                        .background(isMainActive ? Color.orange : Color.timsFieldTan)
                                        .foregroundColor(.timsDarkBrown)
                                        .cornerRadius(12)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        
                        if structuralSubMenusList.count > 1 {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    let showAllActive = selectedSubcategory == nil
                                    
                                    Text("All")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(.timsDarkBrown)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(showAllActive ? Color.orange : Color.timsFieldTan.opacity(0.6))
                                        .cornerRadius(16)
                                        .onTapGesture {
                                            SoundManager.shared.playSound(named: "pop", withExtension: "mp3")
                                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                                selectedSubcategory = nil
                                            }
                                        }
                                    
                                    ForEach(structuralSubMenusList, id: \.self) { subName in
                                        let isSubActive = selectedSubcategory?.lowercased() == subName.lowercased()
                                        
                                        Button(action: {
                                            SoundManager.shared.playSound(named: "pop", withExtension: "mp3")
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                if isSubActive {
                                                    selectedSubcategory = nil
                                                } else {
                                                    selectedSubcategory = subName
                                                }
                                            }
                                        }) {
                                            Text(subName)
                                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                                .foregroundColor(.timsDarkBrown)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 6)
                                                .background(isSubActive ? Color.orange : Color.timsFieldTan.opacity(0.6))
                                                .cornerRadius(16)
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
                    
                    // Dynamic Scroll Catalog Grid area canvas layout
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
                            .padding(.bottom, 90)
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
                
                if !pendingItems.isEmpty && temporarySelectedItem == nil && !isShowingBasketSummary {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                SoundManager.shared.playSound(named: "click", withExtension: "mp3")
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    isShowingBasketSummary = true
                                }
                            }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "basket.fill")
                                        Text("View Basket (\(pendingItems.reduce(0) { $0 + $1.quantity }))")
                                            .font(.system(size: 14, weight: .black, design: .rounded))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    .background(Color.timsRed)
                                    .cornerRadius(30)
                                    .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                        }
                    }
                    .zIndex(3)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Selection Checkout Drawer card container block
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
                                        isShowingBasketSummary = true
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
            // Absolute Bottom Safe Area Pinning overlay presentation blocks
            .overlay(alignment: .bottom) {
                if isShowingBasketSummary && temporarySelectedItem == nil {
                    ZStack(alignment: .bottom) {
                        // Full Screen Backdrop Dimmer Layer
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    isShowingBasketSummary = false
                                }
                            }
                        
                        // The Bottom-Pinned Detail Card View sheet configuration layouts
                        VStack(alignment: .leading, spacing: 16) {
                            // Pull handle visual decorator
                            HStack {
                                Spacer()
                                Capsule()
                                    .frame(width: 40, height: 5)
                                    .foregroundColor(.brown.opacity(0.3))
                                Spacer()
                            }
                            .padding(.top, 4)
                            
                            // Basket Totals Header view components
                            HStack {
                                Text("\(personName.isEmpty ? "Guest" : personName)'s Basket (\(pendingItems.reduce(0) { $0 + $1.quantity }) items)")
                                    .font(.system(size: 13, weight: .black, design: .rounded))
                                    .foregroundColor(.timsDarkBrown)
                                Spacer()
                                Text("$\(String(format: "%.2f", computedBasketTotal))")
                                    .font(.system(size: 14, weight: .black, design: .rounded))
                                    .foregroundColor(.timsRed)
                            }
                            
                            Divider()
                            
                            // Scrollable list breakdown showcasing quantities, text customizations, and inline deletion triggers
                            ScrollView(.vertical, showsIndicators: true) {
                                VStack(spacing: 12) {
                                    ForEach(pendingItems.indices, id: \.self) { index in
                                        let item = pendingItems[index]
                                        
                                        HStack(alignment: .center, spacing: 10) {
                                            // Remove action buttons
                                            Button(action: {
                                                SoundManager.shared.playSound(named: "pop", withExtension: "mp3")
                                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                                    pendingItems.remove(at: index)
                                                    
                                                    if pendingItems.isEmpty {
                                                        isShowingBasketSummary = false
                                                    }
                                                }
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 18))
                                                    .foregroundColor(.timsRed.opacity(0.7))
                                            }
                                            .buttonStyle(.plain)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(item.itemName)
                                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                                    .foregroundColor(.timsDarkBrown)
                                                
                                                if !item.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                    Text("“\(item.notes)”")
                                                        .font(.system(size: 12, design: .rounded))
                                                        .foregroundColor(.secondary)
                                                        .italic()
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            // Inline quantity modifier controls
                                            HStack(spacing: 10) {
                                                Button(action: {
                                                    if pendingItems[index].quantity > 1 {
                                                        SoundManager.shared.playSound(named: "click", withExtension: "mp3")
                                                        withAnimation {
                                                            pendingItems[index].quantity -= 1
                                                        }
                                                    }
                                                }) {
                                                    Image(systemName: "minus.circle")
                                                        .font(.system(size: 16, weight: .bold))
                                                        .foregroundColor(item.quantity > 1 ? .timsRed : .brown.opacity(0.4))
                                                }
                                                .buttonStyle(.plain)
                                                
                                                Text("\(item.quantity)")
                                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                                    .foregroundColor(.timsDarkBrown)
                                                    .frame(minWidth: 18)
                                                
                                                Button(action: {
                                                    if pendingItems[index].quantity < 10 {
                                                        SoundManager.shared.playSound(named: "click", withExtension: "mp3")
                                                        withAnimation {
                                                            pendingItems[index].quantity += 1
                                                        }
                                                    }
                                                }) {
                                                    Image(systemName: "plus.circle")
                                                        .font(.system(size: 16, weight: .bold))
                                                        .foregroundColor(.timsRed)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 4)
                                            .background(Color.timsFieldTan.opacity(0.5))
                                            .cornerRadius(8)
                                            
                                            Text("$\(String(format: "%.2f", item.itemTotal))")
                                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                                .foregroundColor(.timsDarkBrown.opacity(0.8))
                                                .frame(minWidth: 50, alignment: .trailing)
                                        }
                                        .padding(10)
                                        .background(Color.timsFieldTan.opacity(0.3))
                                        .cornerRadius(10)
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                            .frame(maxHeight: 180)
                            
                            Divider()
                            
                            Toggle(isOn: $saveAsFavorite) {
                                Label("Save this complete order as Favorite", systemImage: "star.fill")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.orange)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .orange))
                            
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
                                let cleanedName = personName.trimmingCharacters(in: .whitespacesAndNewlines)
                                if cleanedName.isEmpty {
                                    SoundManager.shared.playSound(named: "buzzer", withExtension: "mp3")
                                    showingNameWarningAlert = true
                                } else {
                                    SoundManager.shared.playSound(named: "success", withExtension: "mp3")
                                    
                                    var finalItemsForManifest = pendingItems
                                    if useDrinkCredit {
                                        let beveragesIndices = finalItemsForManifest.indices.filter { idx in
                                            let name = finalItemsForManifest[idx].itemName.lowercased()
                                            return name.contains("coffee") || name.contains("capp") || name.contains("latte") || name.contains("tea") || name.contains("quencher") || name.contains("drink") ||
                                                   name.contains("brew") || name.contains("lemonade") || name.contains("chocolate")
                                        }
                                        
                                        if let highestIdx = beveragesIndices.max(by: { finalItemsForManifest[$0].unitPrice < finalItemsForManifest[$1].unitPrice }) {
                                            let originalUnitPrice = finalItemsForManifest[highestIdx].unitPrice
                                            let discount = min(originalUnitPrice, 6.00)
                                            
                                            if finalItemsForManifest[highestIdx].quantity > 1 {
                                                finalItemsForManifest[highestIdx].quantity -= 1
                                                
                                                let discountedSingleItem = OrderItem(
                                                    itemName: finalItemsForManifest[highestIdx].itemName + " (Credit Applied 🌟)",
                                                    quantity: 1,
                                                    notes: finalItemsForManifest[highestIdx].notes,
                                                    unitPrice: originalUnitPrice - discount
                                                )
                                                finalItemsForManifest.append(discountedSingleItem)
                                            } else {
                                                finalItemsForManifest[highestIdx].itemName += " (Credit Applied 🌟)"
                                                finalItemsForManifest[highestIdx].unitPrice = originalUnitPrice - discount
                                            }
                                        }
                                    }
                                    
                                    if useDrinkCredit, let index = appStore.userProfiles.firstIndex(where: { $0.name.lowercased() == personName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }) {
                                        if appStore.userProfiles[index].drinkCreditsBalance > 0 {
                                            appStore.userProfiles[index].drinkCreditsBalance -= 1
                                        }
                                    }
                                    
                                    let finalGroupOrder = TeamOrder(
                                        name: personName.isEmpty ? "Guest" : personName,
                                        items: finalItemsForManifest,
                                        isSavedAsFavorite: saveAsFavorite
                                    )
                                    
                                    if saveAsFavorite {
                                        appStore.saveFavoriteBasket(for: personName, items: pendingItems)
                                    }
                                    
                                    if let original = editingOrder,
                                       let index = appStore.activeOrders.firstIndex(where: { $0.id == original.id }) {
                                        appStore.activeOrders[index] = finalGroupOrder
                                    } else {
                                        appStore.saveOrderToActiveRun(finalGroupOrder)
                                    }
                                    isShowingBasketSummary = false
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
                            .disabled(personName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && pendingItems.isEmpty)
                            .opacity(personName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                        }
                        .padding([.horizontal, .top], 16)
                        .padding(.bottom, 34)
                        .background(Color.timsTan)
                        .cornerRadius(20, corners: [.topLeft, .topRight])
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -4)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(3)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .zIndex(6)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(editingOrder == nil ? "Build Order" : "Modify Order")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.orange)
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
