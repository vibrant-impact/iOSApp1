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

// Individual Ordered Item Structure
struct OrderItem: Identifiable, Codable {
    var id = UUID()
    var itemName: String
    var quantity: Int
    var notes: String
    var unitPrice: Double
    
    var itemTotal: Double {
        return Double(quantity) * unitPrice
    }
}

// Team Order Model
// Represents a single team member's compiled order for the day
struct TeamOrder: Identifiable, Codable {
    var id = UUID()
    var name: String
    
    // Explicit dynamic array representing all chosen products inside the passenger's basket
    var items: [OrderItem]
    var isSavedAsFavorite: Bool
    
    // Dynamically calculates the overall checkout scale for this specific individual
    var checkoutTotal: Double {
        return items.reduce(0) { $0 + $1.itemTotal }
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
