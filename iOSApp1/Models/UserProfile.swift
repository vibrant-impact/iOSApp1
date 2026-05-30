//
//  UserProfile.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-29.
//

import Foundation

// MARK: - Completed Run Analytics Record Blueprint
struct PastRunRecord: Identifiable, Codable {
    var id = UUID()
    var completionDate = Date()
    var totalSecondsElapsed: Int
    var targetLimitSeconds: Int
    var earnedACredit: Bool
    
    var wasUnderFifteenMinutes: Bool {
        return totalSecondsElapsed <= targetLimitSeconds
    }
}

// MARK: - Core User Profile System Blueprint
struct UserProfile: Identifiable, Codable {
    var id = UUID()
    var name: String
    
    // Core Balances
    var drinkCreditsBalance: Int = 0
    
    // Saved Templates (Option A: Saved Basket Configurations)
    var savedFavoriteItems: [OrderItem] = []
    
    // Analytics & History Logs
    var pastOrdersHistory: [[OrderItem]] = [] // Arrays of past items ordered
    var runPerformanceHistory: [PastRunRecord] = [] // Tracks their historical driving speed metrics
}
