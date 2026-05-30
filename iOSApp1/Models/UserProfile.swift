//
//  UserProfile.swift
//  iOSApp1
//
//  Created by stephanie otteson on 2026-05-29.
//

import Foundation

struct UserProfile: Identifiable, Codable {
    var id = UUID()
    var name: String
    var accumulatedRewardCredits: Int
    var savedFavoriteItems: [OrderItem] // Links directly to your multi-item basket structure!
}
