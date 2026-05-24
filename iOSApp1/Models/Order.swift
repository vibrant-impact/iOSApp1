//
//  Order.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-21.
//

import Foundation
import Combine

// Tracks individual items within someone's order
struct OrderItem: Hashable {
    var itemName: String
    var quantity: Int = 1
    var notes: String = ""
}

// Represents a single team member's full order for the day
struct TeamOrder: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var drink: OrderItem = OrderItem(itemName: "Double Double")
    var food: OrderItem = OrderItem(itemName: "None")
    var isSavedAsFavorite: Bool = false
}

// Summary of the entire collective group run
struct CompletedRunSummary: Identifiable {
    let id = UUID()
    var dateCompleted: Date
    var runnerName: String
    var totalItemsOrdered: Int
    var timeTakenSeconds: Int
    var earnedCredit: Bool
}

// Represents a single completed coffee run entry for the history log
struct PastRunEntry: Identifiable {
    let id = UUID()
    var dateCompleted: Date
    var totalDrinksOrdered: Int
    var runnerName: String
}

// Represents an individual team member and their drink preferences
struct TeamMember: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var favoriteDrink: String
    var defaultCreamCount: Int
    var defaultSugarCount: Int
}


