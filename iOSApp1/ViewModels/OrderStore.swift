//
//  OrderStore.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-23.
//

import Foundation
import Combine

class OrderStore: ObservableObject {
    let drinkOptions = ["Double Double", "Regular Coffee", "Black Coffee", "Iced Capp", "Vanilla Dip Latte", "Tea"]
    let foodOptions = ["None", "Boston Cream Donut", "Apple Fritter", "Everything Bagel", "Farmers Wrap", "Hashbrown"]
    
    @Published var activeOrders: [TeamOrder] = []
    @Published var runHistory: [CompletedRunSummary] = []
    @Published var currentRunner: String = ""
    
    // Pre-populating some favorites for testing
    @Published var savedFavorites: [TeamOrder] = [
        TeamOrder(
            name: "Alex",
            drink: OrderItem(itemName: "Double Double", quantity: 1, notes: "Extra hot"),
            food: OrderItem(itemName: "Farmers Wrap", quantity: 1, notes: "Spicy chipotle"),
            isSavedAsFavorite: true
        ),
        TeamOrder(
            name: "Sam",
            drink: OrderItem(itemName: "Iced Capp", quantity: 1, notes: "With chocolate milk"),
            food: OrderItem(itemName: "None", quantity: 1, notes: ""),
            isSavedAsFavorite: true
        )
    ]
    
    // Computes a list of names purely from the current active run order
    var activeOrderNames: [String] {
        activeOrders.map { $0.name }
    }
    
    func saveOrderToActiveRun(_ order: TeamOrder) {
        activeOrders.append(order)
        if order.isSavedAsFavorite {
            if let index = savedFavorites.firstIndex(where: { $0.name.lowercased() == order.name.lowercased() }) {
                savedFavorites[index] = order // Update existing profile
            } else {
                savedFavorites.append(order) // Save brand new profile
            }
        }
    }
    
    func resetActiveRun() {
        activeOrders.removeAll()
        currentRunner = ""
    }
}

