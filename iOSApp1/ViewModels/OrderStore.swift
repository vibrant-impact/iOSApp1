//
//  OrderStore.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-21.
//

import Foundation
import Combine

class OrderStore: ObservableObject {
    
    // MARK: - Master Product Inventories
    @Published var allProducts: [JSONProduct] = []
    @Published var activeOrders: [TeamOrder] = []
    @Published var runHistory: [CompletedRunSummary] = []
    @Published var currentRunner: String = ""
    @Published var savedFavorites: [TeamOrder] = []
    
    // Calculated array extracting active names for dynamic runner picking
    var activeOrderNames: [String] {
        activeOrders.map { $0.name }
    }
    
    // MARK: - Initializer Block
    init() {
        loadJsonInventory()
    }
    
    // MARK: - JSON Parser Logic
    /// Decodes the local productData.json file straight from the primary bundle directory ledger
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
            
        } catch {
            print("⚠️ OrderStore Error: Failed parsing JSON inventory data: \(error)")
        }
    }
    
    // MARK: - Functional Manifest Utilities
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
