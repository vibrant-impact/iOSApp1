//
//  Order.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-21.
//

import Foundation
import Combine

// JSON Product Model
// Maps to productData.json properties data keys
struct JSONProduct: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let category: String
    let image: String
}

// Order Item Model
// Tracks individual items selected from the product catalog or created manually
struct OrderItem: Hashable {
    var itemName: String
    var quantity: Int = 1
    var notes: String = ""
    var unitPrice: Double = 0.0
}

// Team Order Model
// Represents a single team member's compiled order for the day
struct TeamOrder: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var drink: OrderItem = OrderItem(itemName: "Brewed Coffee", unitPrice: 1.83)
    var food: OrderItem = OrderItem(itemName: "None", unitPrice: 0.0)
    var isSavedAsFavorite: Bool = false
        
    // Calculated total price value for a clean checkout configuration experience
    var checkoutTotal: Double {
        let drinkCost = drink.unitPrice * Double(drink.quantity)
        let foodCost = food.unitPrice * Double(food.quantity)
        return drinkCost + foodCost
    }
}

// Run Summary Model
// Tracks the history details of completed group coffee run sequences
struct CompletedRunSummary: Identifiable {
    let id = UUID()
    var dateCompleted: Date
    var runnerName: String
    var totalItemsOrdered: Int
    var timeTakenSeconds: Int
    var earnedCredit: Bool
}
