//
//  AvatarViewModelTests.swift
//  IOS_Student_HavenTests
//
//  Created on 12/7/24.
//

import XCTest
@testable import IOS_Student_Haven

@MainActor
final class AvatarViewModelTests: XCTestCase {
    
    var viewModel: AvatarViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        viewModel = AvatarViewModel()
        // Clear any existing data
        UserDefaults.standard.removeObject(forKey: "user_avatar")
        UserDefaults.standard.removeObject(forKey: "partner_preferences")
        UserDefaults.standard.removeObject(forKey: "owned_collections")
    }
    
    override func tearDown() async throws {
        viewModel = nil
        UserDefaults.standard.removeObject(forKey: "user_avatar")
        UserDefaults.standard.removeObject(forKey: "partner_preferences")
        UserDefaults.standard.removeObject(forKey: "owned_collections")
        try await super.tearDown()
    }
    
    // MARK: - Avatar Creation Tests
    
    func testCreateAvatar() {
        XCTAssertNil(viewModel.myAvatar)
        
        viewModel.createAvatar(name: "Test User", gender: .male)
        
        XCTAssertNotNil(viewModel.myAvatar)
        XCTAssertEqual(viewModel.myAvatar?.name, "Test User")
        XCTAssertEqual(viewModel.myAvatar?.gender, .male)
    }
    
    func testHasAvatar() {
        XCTAssertFalse(viewModel.hasAvatar())
        
        viewModel.createAvatar(name: "Test", gender: .female)
        
        XCTAssertTrue(viewModel.hasAvatar())
    }
    
    // MARK: - Appearance Update Tests
    
    func testUpdateAppearance() {
        viewModel.createAvatar(name: "Test", gender: .other)
        
        let newAppearance = Appearance(
            skinTone: .dark,
            faceShape: .square,
            hairStyle: .long,
            hairColor: .red
        )
        
        viewModel.updateAppearance(newAppearance)
        
        XCTAssertEqual(viewModel.myAvatar?.appearance.skinTone, .dark)
        XCTAssertEqual(viewModel.myAvatar?.appearance.hairStyle, .long)
    }
    
    // MARK: - Outfit Update Tests
    
    func testUpdateOutfit() {
        viewModel.createAvatar(name: "Test", gender: .male)
        
        let top = ClothingItem(name: "New Shirt", category: .top)
        let bottom = ClothingItem(name: "New Pants", category: .bottom)
        let outfit = Outfit(top: top, bottom: bottom)
        
        viewModel.updateOutfit(outfit)
        
        XCTAssertEqual(viewModel.myAvatar?.currentOutfit.top?.name, "New Shirt")
        XCTAssertEqual(viewModel.myAvatar?.currentOutfit.bottom?.name, "New Pants")
    }
    
    // MARK: - Clothing Management Tests
    
    func testAddClothingItem() {
        viewModel.createAvatar(name: "Test", gender: .female)
        
        let initialCount = viewModel.myAvatar?.ownedClothingItems.count ?? 0
        
        let newItem = ClothingItem(name: "Premium Shirt", category: .top, isPremium: true, price: 1.99)
        viewModel.addClothingItem(newItem)
        
        XCTAssertEqual(viewModel.myAvatar?.ownedClothingItems.count, initialCount + 1)
        XCTAssertTrue(viewModel.myAvatar?.ownedClothingItems.contains(where: { $0.id == newItem.id }) ?? false)
    }
    
    func testAddDuplicateClothingItem() {
        viewModel.createAvatar(name: "Test", gender: .male)
        
        let item = ClothingItem(name: "Test Item", category: .top)
        viewModel.addClothingItem(item)
        
        let countAfterFirst = viewModel.myAvatar?.ownedClothingItems.count ?? 0
        
        viewModel.addClothingItem(item)
        
        let countAfterSecond = viewModel.myAvatar?.ownedClothingItems.count ?? 0
        
        XCTAssertEqual(countAfterFirst, countAfterSecond, "Should not add duplicate items")
    }
    
    func testPurchaseCollection() {
        viewModel.createAvatar(name: "Test", gender: .male)
        
        let collection = ClothingCollection.fallCollection
        let initialCount = viewModel.myAvatar?.ownedClothingItems.count ?? 0
        
        viewModel.purchaseCollection(collection)
        
        let finalCount = viewModel.myAvatar?.ownedClothingItems.count ?? 0
        XCTAssertTrue(finalCount > initialCount)
        XCTAssertTrue(viewModel.isCollectionOwned(collection))
    }
    
    func testIsCollectionOwned() {
        viewModel.createAvatar(name: "Test", gender: .female)
        
        let collection = ClothingCollection.professionalCollection
        
        XCTAssertFalse(viewModel.isCollectionOwned(collection))
        
        viewModel.purchaseCollection(collection)
        
        XCTAssertTrue(viewModel.isCollectionOwned(collection))
    }
    
    // MARK: - Partner Preferences Tests
    
    func testUpdatePartnerPreferences() {
        let preferences = StudyPartnerPreferences(
            preferredGender: .female,
            ageRange: 20...25,
            matchingEnabled: true
        )
        
        viewModel.updatePartnerPreferences(preferences)
        
        XCTAssertNotNil(viewModel.idealPartnerPreferences)
        XCTAssertEqual(viewModel.idealPartnerPreferences?.preferredGender, .female)
        XCTAssertEqual(viewModel.idealPartnerPreferences?.ageRange, 20...25)
        XCTAssertTrue(viewModel.idealPartnerPreferences?.matchingEnabled ?? false)
    }
    
    // MARK: - Compatibility Tests
    
    func testCalculateCompatibilityWithMatchingDisabled() {
        viewModel.createAvatar(name: "User1", gender: .male)
        
        let preferences = StudyPartnerPreferences(matchingEnabled: false)
        viewModel.updatePartnerPreferences(preferences)
        
        let otherAvatar = Avatar(name: "User2", gender: .female)
        let score = viewModel.calculateCompatibility(with: otherAvatar)
        
        XCTAssertEqual(score, 0, "Score should be 0 when matching is disabled")
    }
    
    func testCalculateCompatibilityWithGenderMatch() {
        viewModel.createAvatar(name: "User1", gender: .male)
        
        let preferences = StudyPartnerPreferences(
            preferredGender: .female,
            matchingEnabled: true
        )
        viewModel.updatePartnerPreferences(preferences)
        
        let otherAvatar = Avatar(name: "User2", gender: .female)
        let score = viewModel.calculateCompatibility(with: otherAvatar)
        
        XCTAssertGreaterThan(score, 0)
        XCTAssertLessThanOrEqual(score, 100)
    }
    
    func testCalculateCompatibilityPerfectMatch() {
        viewModel.createAvatar(name: "User1", gender: .male)
        
        var appearance = Appearance()
        appearance.hairStyle = .long
        appearance.bodyType = .athletic
        appearance.height = .tall
        
        let preferences = StudyPartnerPreferences(
            preferredGender: .female,
            preferredAppearance: AppearancePreferences(
                hairStyles: [.long],
                bodyTypes: [.athletic],
                heights: [.tall]
            ),
            matchingEnabled: true
        )
        viewModel.updatePartnerPreferences(preferences)
        
        var otherAvatar = Avatar(name: "User2", gender: .female)
        otherAvatar.appearance = appearance
        
        let score = viewModel.calculateCompatibility(with: otherAvatar)
        
        XCTAssertEqual(score, 100, "Perfect match should score 100")
    }
    
    // MARK: - Filtering Tests
    
    func testGetFilteredClothingByCategory() {
        viewModel.createAvatar(name: "Test", gender: .male)
        
        let tops = viewModel.getFilteredClothing(category: .top)
        let bottoms = viewModel.getFilteredClothing(category: .bottom)
        
        XCTAssertFalse(tops.isEmpty)
        XCTAssertTrue(tops.allSatisfy { $0.category == .top })
        XCTAssertTrue(bottoms.allSatisfy { $0.category == .bottom })
    }
    
    // MARK: - Persistence Tests
    
    func testAvatarPersistence() {
        viewModel.createAvatar(name: "Persistent User", gender: .female)
        
        // Create a new view model to test loading
        let newViewModel = AvatarViewModel()
        
        XCTAssertNotNil(newViewModel.myAvatar)
        XCTAssertEqual(newViewModel.myAvatar?.name, "Persistent User")
        XCTAssertEqual(newViewModel.myAvatar?.gender, .female)
    }
    
    func testPreferencesPersistence() {
        let preferences = StudyPartnerPreferences(
            preferredGender: .male,
            ageRange: 22...30,
            matchingEnabled: true
        )
        
        viewModel.updatePartnerPreferences(preferences)
        
        // Create a new view model to test loading
        let newViewModel = AvatarViewModel()
        
        XCTAssertNotNil(newViewModel.idealPartnerPreferences)
        XCTAssertEqual(newViewModel.idealPartnerPreferences?.preferredGender, .male)
        XCTAssertEqual(newViewModel.idealPartnerPreferences?.ageRange.lowerBound, 22)
    }
}
