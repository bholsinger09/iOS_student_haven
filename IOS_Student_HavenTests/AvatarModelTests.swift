//
//  AvatarModelTests.swift
//  IOS_Student_HavenTests
//
//  Created on 12/7/24.
//

import XCTest
@testable import IOS_Student_Haven

final class AvatarModelTests: XCTestCase {
    
    // MARK: - Avatar Creation Tests
    
    func testAvatarInitialization() {
        let avatar = Avatar(name: "Test User", gender: .male)
        
        XCTAssertEqual(avatar.name, "Test User")
        XCTAssertEqual(avatar.gender, .male)
        XCTAssertNotNil(avatar.id)
        XCTAssertEqual(avatar.ownedClothingItems.count, 5, "Avatar should start with 5 default clothing items")
    }
    
    func testAvatarHasDefaultClothing() {
        let avatar = Avatar()
        let defaultItems = ClothingItem.defaultItems
        
        XCTAssertEqual(avatar.ownedClothingItems.count, defaultItems.count)
        XCTAssertTrue(avatar.ownedClothingItems.contains(where: { $0.name == "Plain T-Shirt" }))
        XCTAssertTrue(avatar.ownedClothingItems.contains(where: { $0.name == "Basic Jeans" }))
    }
    
    // MARK: - Appearance Tests
    
    func testAppearanceInitialization() {
        let appearance = Appearance()
        
        XCTAssertEqual(appearance.skinTone, .medium)
        XCTAssertEqual(appearance.faceShape, .oval)
        XCTAssertEqual(appearance.hairStyle, .short)
        XCTAssertEqual(appearance.hairColor, .brown)
    }
    
    func testSkinToneColors() {
        XCTAssertNotNil(SkinTone.veryLight.color)
        XCTAssertNotNil(SkinTone.dark.color)
        XCTAssertEqual(SkinTone.allCases.count, 6)
    }
    
    // MARK: - Clothing Tests
    
    func testClothingItemCreation() {
        let item = ClothingItem(
            name: "Test Shirt",
            category: .top,
            isPremium: true,
            price: 1.99
        )
        
        XCTAssertEqual(item.name, "Test Shirt")
        XCTAssertEqual(item.category, .top)
        XCTAssertTrue(item.isPremium)
        XCTAssertEqual(item.price, 1.99)
    }
    
    func testDefaultClothingItems() {
        let items = ClothingItem.defaultItems
        
        XCTAssertEqual(items.count, 5)
        XCTAssertTrue(items.allSatisfy { !$0.isPremium })
        XCTAssertTrue(items.allSatisfy { $0.price == nil })
    }
    
    // MARK: - Outfit Tests
    
    func testOutfitInitialization() {
        let outfit = Outfit()
        
        XCTAssertNil(outfit.top)
        XCTAssertNil(outfit.bottom)
        XCTAssertNil(outfit.shoes)
        XCTAssertNil(outfit.outerwear)
        XCTAssertTrue(outfit.accessories.isEmpty)
    }
    
    func testOutfitWithItems() {
        let top = ClothingItem(name: "Shirt", category: .top)
        let bottom = ClothingItem(name: "Pants", category: .bottom)
        
        let outfit = Outfit(top: top, bottom: bottom)
        
        XCTAssertEqual(outfit.top?.name, "Shirt")
        XCTAssertEqual(outfit.bottom?.name, "Pants")
        XCTAssertNil(outfit.shoes)
    }
    
    // MARK: - Collection Tests
    
    func testClothingCollections() {
        let collections = ClothingCollection.allCollections
        
        XCTAssertEqual(collections.count, 4)
        XCTAssertTrue(collections.contains(where: { $0.name == "Fall Collection" }))
        XCTAssertTrue(collections.contains(where: { $0.name == "Professional" }))
    }
    
    func testFallCollectionContents() {
        let fallCollection = ClothingCollection.fallCollection
        
        XCTAssertEqual(fallCollection.name, "Fall Collection")
        XCTAssertFalse(fallCollection.items.isEmpty)
        XCTAssertEqual(fallCollection.price, 4.99)
        XCTAssertTrue(fallCollection.items.allSatisfy { $0.isPremium })
    }
    
    // MARK: - Gender Tests
    
    func testGenderCases() {
        XCTAssertEqual(Gender.allCases.count, 3)
        XCTAssertEqual(Gender.male.rawValue, "Male")
        XCTAssertEqual(Gender.female.rawValue, "Female")
        XCTAssertEqual(Gender.other.rawValue, "Non-binary")
    }
    
    // MARK: - Codable Tests
    
    func testAvatarCodable() throws {
        let original = Avatar(name: "Test", gender: .female)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Avatar.self, from: data)
        
        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.gender, original.gender)
        XCTAssertEqual(decoded.id, original.id)
    }
    
    func testAppearanceCodable() throws {
        let original = Appearance(
            skinTone: .dark,
            faceShape: .round,
            hairStyle: .curly,
            hairColor: .black
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Appearance.self, from: data)
        
        XCTAssertEqual(decoded.skinTone, original.skinTone)
        XCTAssertEqual(decoded.faceShape, original.faceShape)
        XCTAssertEqual(decoded.hairStyle, original.hairStyle)
        XCTAssertEqual(decoded.hairColor, original.hairColor)
    }
}
