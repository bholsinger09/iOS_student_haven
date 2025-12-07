//
//  AvatarViewModel.swift
//  IOS_Student_Haven
//
//  Created on 12/7/24.
//

import Foundation
import SwiftUI

@MainActor
class AvatarViewModel: ObservableObject {
    @Published var myAvatar: Avatar?
    @Published var idealPartnerPreferences: StudyPartnerPreferences?
    @Published var isEditingAvatar = false
    @Published var isEditingPreferences = false
    @Published var ownedCollections: Set<UUID> = []
    
    private let avatarKey = "user_avatar"
    private let preferencesKey = "partner_preferences"
    private let collectionsKey = "owned_collections"
    
    init() {
        loadAvatar()
        loadPreferences()
        loadOwnedCollections()
    }
    
    // MARK: - Avatar Management
    func createAvatar(name: String, gender: Gender) {
        let newAvatar = Avatar(name: name, gender: gender)
        self.myAvatar = newAvatar
        saveAvatar()
    }
    
    func updateAvatar(_ avatar: Avatar) {
        self.myAvatar = avatar
        saveAvatar()
    }
    
    func updateAppearance(_ appearance: Appearance) {
        guard var avatar = myAvatar else { return }
        avatar.appearance = appearance
        avatar.lastModified = Date()
        myAvatar = avatar
        saveAvatar()
    }
    
    func updateOutfit(_ outfit: Outfit) {
        guard var avatar = myAvatar else { return }
        avatar.currentOutfit = outfit
        avatar.lastModified = Date()
        myAvatar = avatar
        saveAvatar()
    }
    
    func addClothingItem(_ item: ClothingItem) {
        guard var avatar = myAvatar else { return }
        if !avatar.ownedClothingItems.contains(where: { $0.id == item.id }) {
            avatar.ownedClothingItems.append(item)
            avatar.lastModified = Date()
            myAvatar = avatar
            saveAvatar()
        }
    }
    
    func purchaseCollection(_ collection: ClothingCollection) {
        // Add all items from collection to avatar's owned items
        guard var avatar = myAvatar else { return }
        
        for item in collection.items {
            if !avatar.ownedClothingItems.contains(where: { $0.id == item.id }) {
                avatar.ownedClothingItems.append(item)
            }
        }
        
        ownedCollections.insert(collection.id)
        avatar.lastModified = Date()
        myAvatar = avatar
        
        saveAvatar()
        saveOwnedCollections()
    }
    
    func isCollectionOwned(_ collection: ClothingCollection) -> Bool {
        return ownedCollections.contains(collection.id)
    }
    
    // MARK: - Partner Preferences
    func updatePartnerPreferences(_ preferences: StudyPartnerPreferences) {
        self.idealPartnerPreferences = preferences
        savePreferences()
    }
    
    func calculateCompatibility(with otherAvatar: Avatar) -> Int {
        guard let preferences = idealPartnerPreferences else { return 0 }
        guard preferences.matchingEnabled else { return 0 }
        
        var score = 0
        let maxScore = 100
        
        // Gender match (30 points)
        if let preferredGender = preferences.preferredGender {
            if otherAvatar.gender == preferredGender {
                score += 30
            }
        } else {
            score += 15 // No preference = partial points
        }
        
        // Hair style match (20 points)
        if preferences.preferredAppearance.hairStyles.isEmpty {
            score += 10
        } else if preferences.preferredAppearance.hairStyles.contains(otherAvatar.appearance.hairStyle) {
            score += 20
        }
        
        // Body type match (20 points)
        if preferences.preferredAppearance.bodyTypes.isEmpty {
            score += 10
        } else if preferences.preferredAppearance.bodyTypes.contains(otherAvatar.appearance.bodyType) {
            score += 20
        }
        
        // Height match (20 points)
        if preferences.preferredAppearance.heights.isEmpty {
            score += 10
        } else if preferences.preferredAppearance.heights.contains(otherAvatar.appearance.height) {
            score += 20
        }
        
        // Style match based on clothing (10 points)
        score += 10
        
        return min(score, maxScore)
    }
    
    // MARK: - Persistence
    private func saveAvatar() {
        guard let avatar = myAvatar else { return }
        if let encoded = try? JSONEncoder().encode(avatar) {
            UserDefaults.standard.set(encoded, forKey: avatarKey)
        }
    }
    
    private func loadAvatar() {
        if let data = UserDefaults.standard.data(forKey: avatarKey),
           let decoded = try? JSONDecoder().decode(Avatar.self, from: data) {
            myAvatar = decoded
        }
    }
    
    private func savePreferences() {
        guard let preferences = idealPartnerPreferences else { return }
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: preferencesKey)
        }
    }
    
    private func loadPreferences() {
        if let data = UserDefaults.standard.data(forKey: preferencesKey),
           let decoded = try? JSONDecoder().decode(StudyPartnerPreferences.self, from: data) {
            idealPartnerPreferences = decoded
        } else {
            idealPartnerPreferences = StudyPartnerPreferences()
        }
    }
    
    private func saveOwnedCollections() {
        let collectionIds = Array(ownedCollections).map { $0.uuidString }
        UserDefaults.standard.set(collectionIds, forKey: collectionsKey)
    }
    
    private func loadOwnedCollections() {
        if let ids = UserDefaults.standard.array(forKey: collectionsKey) as? [String] {
            ownedCollections = Set(ids.compactMap { UUID(uuidString: $0) })
        }
    }
    
    // MARK: - Helper Methods
    func getFilteredClothing(category: ClothingCategory) -> [ClothingItem] {
        guard let avatar = myAvatar else { return [] }
        return avatar.ownedClothingItems.filter { $0.category == category }
    }
    
    func hasAvatar() -> Bool {
        return myAvatar != nil
    }
}
