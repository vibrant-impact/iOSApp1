//
//  OrderStore.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-21.
//

import Foundation
import Combine

class OrderStore: ObservableObject {
    // Master Product Inventories
    @Published var allProducts: [JSONProduct] = []
    @Published var activeOrders: [TeamOrder] = []
    @Published var runHistory: [CompletedRunSummary] = []
    @Published var currentRunner: String = ""
    @Published var savedFavorites: [TeamOrder] = []
    
    // Filtered Categories Cache
    @Published var drinkOptions: [String] = []
    @Published var foodOptions: [String] = []
    
    // Calculated array extracting active names for dynamic runner picking
    var activeOrderNames: [String] {
        activeOrders.map { $0.name }
    }
    
    // Initializer Block
    init() {
        loadJsonInventory()
    }
    
    // JSON Parser Logic
    // Decodes the local productData.json file straight from the primary bundle directory ledger
    private func loadJsonInventory() {
        guard let url = Bundle.main.url(forResource: "productData", withExtension: "json") else {
            print("⚠️ OrderStore Error: Unable to locate productData.json in bundle framework")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedProducts = try JSONDecoder().decode([JSONProduct].self, from: data)
            
            // Assign parsed data array to main publisher pipeline
            self.allProducts = decodedProducts
            
            // Extract distinct names based on JSON category classifications
            extractMenuCategories(from: decodedProducts)
            
        } catch {
            print("⚠️ OrderStore Error: Failed parsing JSON inventory data: \(error)")
        }
    }
    
    // Splits raw categories into clean dropdown pick arrays for drinks and snacks
    private func extractMenuCategories(from products: [JSONProduct]) {
        // Automatically isolate hot/cold drink categories
        let drinks = products.filter { $0.category.lowercased().contains("drink") || $0.category.lowercased().contains("coffee") || $0.category.lowercased().contains("tea") }
        self.drinkOptions = Array(Set(drinks.map { $0.name })).sorted()
        
        // Isolate remaining structural items like baked goods, sandwiches, wraps, and tarts
        let snacks = products.filter { !drinks.contains($0) }
        self.foodOptions = Array(Set(snacks.map { $0.name })).sorted()
    }
    
    // Functional Manifest Utilities
    func saveOrderToActiveRun(_ order: TeamOrder) {
        activeOrders.append(order)
        if order.isSavedAsFavorite {
            if let index = savedFavorites.firstIndex(where: { $0.name.lowercased() == order.name.lowercased() }) {
                savedFavorites[index] = order
            } else {
                savedFavorites.append(order)
            }
        }
    }
    
    func resetActiveRun() {
        activeOrders.removeAll()
        currentRunner = ""
    }
}
