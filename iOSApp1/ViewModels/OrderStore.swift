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
    
    @Published var userProfiles: [UserProfile] = [] {
        didSet {
            saveProfilesToHardware()
        }
    }
    
    // MARK: - Initializer Block
    init() {
        loadJsonInventory()
        loadProfilesFromHardware()
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
    
    /// Sweeps the profile array list to find an existing account or spawns a clean one on the fly
    func findOrCreateProfile(for name: String) -> UserProfile {
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let existing = userProfiles.first(where: { $0.name.lowercased() == cleanedName.lowercased() }) {
            return existing
        } else {
            let newProfile = UserProfile(name: cleanedName)
            userProfiles.append(newProfile)
            return newProfile
        }
    }

    /// Updates or appends a targeted favorite basket configuration to a specific profile account
    func saveFavoriteBasket(for name: String, items: [OrderItem]) {
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty else { return }
        
        if let index = userProfiles.firstIndex(where: { $0.name.lowercased() == cleanedName.lowercased() }) {
            userProfiles[index].savedFavoriteItems = items
        } else {
            var newProfile = UserProfile(name: cleanedName)
            newProfile.savedFavoriteItems = items
            userProfiles.append(newProfile)
        }
    }

    /// Increments the drink token reward ledger for the current driver profile instance
    func awardDrinkCredit(to runnerName: String, elapsedSeconds: Int, targetSeconds: Int, creditEarned: Bool) {
        let cleanedName = runnerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty, let index = userProfiles.firstIndex(where: { $0.name.lowercased() == cleanedName.lowercased() }) else { return }
        
        // Create the analytical history log record
        let newRunRecord = PastRunRecord(
            totalSecondsElapsed: elapsedSeconds,
            targetLimitSeconds: targetSeconds,
            earnedACredit: creditEarned
        )
        
        userProfiles[index].runPerformanceHistory.append(newRunRecord)
        if creditEarned {
            userProfiles[index].drinkCreditsBalance += 1
        }
    }

    // MARK: - Hard Disk Data Persistence Mechanics
    func saveProfilesToHardware() {
        if let encodedData = try? JSONEncoder().encode(userProfiles) {
            UserDefaults.standard.set(encodedData, forKey: "TimsRunnerUserProfilesKey")
        }
    }

    func loadProfilesFromHardware() {
        if let savedData = UserDefaults.standard.data(forKey: "TimsRunnerUserProfilesKey"),
           let decodedProfiles = try? JSONDecoder().decode([UserProfile].self, from: savedData) {
            self.userProfiles = decodedProfiles
        }
    }
    
}
