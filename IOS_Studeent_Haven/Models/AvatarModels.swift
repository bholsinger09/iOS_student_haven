//
//  AvatarModels.swift
//  IOS_Student_Haven
//
//  Created on 12/7/24.
//

import Foundation
import SwiftUI

// MARK: - Avatar
struct Avatar: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var gender: Gender
    var age: Int // Age affects proportions and features
    var appearance: Appearance
    var currentOutfit: Outfit
    var ownedClothingItems: [ClothingItem]
    var createdAt: Date
    var lastModified: Date
    
    // 3D avatar configuration
    var uses3DAvatar: Bool = true // Default to 3D now
    
    // ARKit TrueDepth face scan data (iPhone X+ with TrueDepth camera)
    var arFaceGeometryData: Data? // Serialized ARFaceGeometry (50k+ vertices)
    var arFacePhotoData: Data? // High-quality capture from AR session
    
    // Vision framework face scan data (fallback for older devices)
    var facePhotoData: Data? // Captured photo
    var faceLandmarksData: Data? // Serialized FaceAnalysis
    
    init(id: UUID = UUID(), name: String = "", gender: Gender = .other, age: Int = 25, appearance: Appearance = Appearance(), currentOutfit: Outfit = Outfit()) {
        self.id = id
        self.name = name
        self.gender = gender
        self.age = age
        self.appearance = appearance
        self.currentOutfit = currentOutfit
        self.ownedClothingItems = ClothingItem.defaultItems
        self.createdAt = Date()
        self.lastModified = Date()
        self.uses3DAvatar = true
        self.arFaceGeometryData = nil
        self.arFacePhotoData = nil
        self.facePhotoData = nil
        self.faceLandmarksData = nil
    }
    
    // Check if this has ARKit TrueDepth scan (highest quality)
    var hasTrueDepthScan: Bool {
        return arFaceGeometryData != nil
    }
    
    // Check if this has Vision framework scan (fallback)
    var hasVisionScan: Bool {
        return facePhotoData != nil && faceLandmarksData != nil
    }
    
    // Check if this is any type of face-scanned avatar
    var isFaceScanned: Bool {
        return hasTrueDepthScan || hasVisionScan
    }
    
    // Age category for proportions
    var ageCategory: AgeCategory {
        switch age {
        case 18...24: return .youngAdult
        case 25...35: return .adult
        case 36...50: return .middleAged
        default: return .senior
        }
    }
}

// MARK: - Age Category
enum AgeCategory: String, Codable {
    case youngAdult = "Young Adult (18-24)"
    case adult = "Adult (25-35)"
    case middleAged = "Middle Aged (36-50)"
    case senior = "Senior (51+)"
    
    var bodyProportions: BodyProportions {
        switch self {
        case .youngAdult:
            return BodyProportions(headSize: 1.0, shoulderWidth: 0.95, height: 1.0)
        case .adult:
            return BodyProportions(headSize: 0.98, shoulderWidth: 1.0, height: 1.0)
        case .middleAged:
            return BodyProportions(headSize: 0.96, shoulderWidth: 1.05, height: 0.98)
        case .senior:
            return BodyProportions(headSize: 0.95, shoulderWidth: 1.0, height: 0.95)
        }
    }
}

struct BodyProportions: Codable, Equatable {
    var headSize: Float
    var shoulderWidth: Float
    var height: Float
}

// MARK: - Gender
enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Non-binary"
}

// MARK: - Appearance
struct Appearance: Codable, Equatable {
    var skinTone: SkinTone
    var faceShape: FaceShape
    var hairStyle: HairStyle
    var hairColor: HairColor
    var eyeColor: EyeColor
    var eyeShape: EyeShape
    var bodyType: BodyType
    var height: Height
    
    init(skinTone: SkinTone = .medium,
         faceShape: FaceShape = .oval,
         hairStyle: HairStyle = .short,
         hairColor: HairColor = .brown,
         eyeColor: EyeColor = .brown,
         eyeShape: EyeShape = .almond,
         bodyType: BodyType = .average,
         height: Height = .average) {
        self.skinTone = skinTone
        self.faceShape = faceShape
        self.hairStyle = hairStyle
        self.hairColor = hairColor
        self.eyeColor = eyeColor
        self.eyeShape = eyeShape
        self.bodyType = bodyType
        self.height = height
    }
}

// MARK: - Appearance Enums
enum SkinTone: String, Codable, CaseIterable {
    case veryLight = "Very Light"
    case light = "Light"
    case medium = "Medium"
    case tan = "Tan"
    case dark = "Dark"
    case veryDark = "Very Dark"
    
    var color: Color {
        switch self {
        case .veryLight: return Color(red: 1.0, green: 0.95, blue: 0.91)
        case .light: return Color(red: 0.98, green: 0.88, blue: 0.78)
        case .medium: return Color(red: 0.93, green: 0.78, blue: 0.62)
        case .tan: return Color(red: 0.82, green: 0.65, blue: 0.48)
        case .dark: return Color(red: 0.65, green: 0.48, blue: 0.36)
        case .veryDark: return Color(red: 0.45, green: 0.32, blue: 0.22)
        }
    }
}

enum FaceShape: String, Codable, CaseIterable {
    case oval = "Oval"
    case round = "Round"
    case square = "Square"
    case heart = "Heart"
    case diamond = "Diamond"
}

enum HairStyle: String, Codable, CaseIterable {
    case short = "Short"
    case medium = "Medium"
    case long = "Long"
    case curly = "Curly"
    case straight = "Straight"
    case wavy = "Wavy"
    case bald = "Bald"
    case buzz = "Buzz Cut"
    
    var isPremium: Bool {
        return false // All basic styles are free
    }
}

enum HairColor: String, Codable, CaseIterable {
    case black = "Black"
    case brown = "Brown"
    case blonde = "Blonde"
    case red = "Red"
    case gray = "Gray"
    case auburn = "Auburn"
    
    var color: Color {
        switch self {
        case .black: return .black
        case .brown: return Color(red: 0.4, green: 0.26, blue: 0.13)
        case .blonde: return Color(red: 0.98, green: 0.94, blue: 0.75)
        case .red: return Color(red: 0.72, green: 0.26, blue: 0.17)
        case .gray: return Color.gray
        case .auburn: return Color(red: 0.65, green: 0.16, blue: 0.16)
        }
    }
}

enum EyeColor: String, Codable, CaseIterable {
    case brown = "Brown"
    case blue = "Blue"
    case green = "Green"
    case hazel = "Hazel"
    case gray = "Gray"
    case amber = "Amber"
    
    var color: Color {
        switch self {
        case .brown: return Color(red: 0.4, green: 0.26, blue: 0.13)
        case .blue: return Color.blue
        case .green: return Color.green
        case .hazel: return Color(red: 0.65, green: 0.55, blue: 0.35)
        case .gray: return Color.gray
        case .amber: return Color.orange
        }
    }
}

enum EyeShape: String, Codable, CaseIterable {
    case almond = "Almond"
    case round = "Round"
    case hooded = "Hooded"
    case upturned = "Upturned"
    case downturned = "Downturned"
}

enum BodyType: String, Codable, CaseIterable {
    case slim = "Slim"
    case average = "Average"
    case athletic = "Athletic"
    case heavy = "Heavy"
}

enum Height: String, Codable, CaseIterable {
    case short = "Short"
    case average = "Average"
    case tall = "Tall"
}

// MARK: - Clothing
struct ClothingItem: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let category: ClothingCategory
    let imageName: String
    let isPremium: Bool
    let price: Double?
    let collectionName: String?
    let color: ClothingColor
    
    init(id: UUID = UUID(),
         name: String,
         category: ClothingCategory,
         imageName: String = "tshirt",
         isPremium: Bool = false,
         price: Double? = nil,
         collectionName: String? = nil,
         color: ClothingColor = .neutral) {
        self.id = id
        self.name = name
        self.category = category
        self.imageName = imageName
        self.isPremium = isPremium
        self.price = price
        self.collectionName = collectionName
        self.color = color
    }
    
    // Default free items that everyone starts with
    static let defaultItems: [ClothingItem] = [
        // Free Tops
        ClothingItem(name: "Plain T-Shirt", category: .top, color: .white),
        ClothingItem(name: "V-Neck Tee", category: .top, color: .gray),
        ClothingItem(name: "Tank Top", category: .top, color: .black),
        ClothingItem(name: "Long Sleeve Shirt", category: .top, color: .blue),
        ClothingItem(name: "Polo Shirt", category: .top, color: .red),
        ClothingItem(name: "Hoodie", category: .top, color: .gray),
        ClothingItem(name: "Sweatshirt", category: .top, color: .green),
        ClothingItem(name: "Button-Up Shirt", category: .top, color: .white),
        
        // Free Bottoms
        ClothingItem(name: "Basic Jeans", category: .bottom, color: .blue),
        ClothingItem(name: "Black Jeans", category: .bottom, color: .black),
        ClothingItem(name: "Cargo Pants", category: .bottom, color: .neutral),
        ClothingItem(name: "Shorts", category: .bottom, color: .gray),
        ClothingItem(name: "Joggers", category: .bottom, color: .black),
        ClothingItem(name: "Khaki Pants", category: .bottom, color: .neutral),
        ClothingItem(name: "Skirt", category: .bottom, color: .black),
        ClothingItem(name: "Leggings", category: .bottom, color: .black),
        
        // Free Shoes
        ClothingItem(name: "White Sneakers", category: .shoes, color: .white),
        ClothingItem(name: "Black Sneakers", category: .shoes, color: .black),
        ClothingItem(name: "Running Shoes", category: .shoes, color: .blue),
        ClothingItem(name: "Boots", category: .shoes, color: .black),
        ClothingItem(name: "Sandals", category: .shoes, color: .neutral),
        ClothingItem(name: "Loafers", category: .shoes, color: .neutral),
        
        // Free Outerwear
        ClothingItem(name: "Denim Jacket", category: .outerwear, color: .blue),
        ClothingItem(name: "Bomber Jacket", category: .outerwear, color: .black),
        ClothingItem(name: "Cardigan", category: .outerwear, color: .gray),
        ClothingItem(name: "Windbreaker", category: .outerwear, color: .blue),
        
        // Free Accessories
        ClothingItem(name: "Baseball Cap", category: .accessories, color: .black),
        ClothingItem(name: "Beanie", category: .accessories, color: .gray),
        ClothingItem(name: "Backpack", category: .accessories, color: .black),
        ClothingItem(name: "Watch", category: .accessories, color: .neutral),
        ClothingItem(name: "Sunglasses", category: .accessories, color: .black),
        ClothingItem(name: "Scarf", category: .accessories, color: .red),
    ]
}

enum ClothingCategory: String, Codable, CaseIterable {
    case top = "Tops"
    case bottom = "Bottoms"
    case shoes = "Shoes"
    case outerwear = "Outerwear"
    case accessories = "Accessories"
    case fullOutfit = "Full Outfits"
}

enum ClothingColor: String, Codable, CaseIterable {
    case red = "Red"
    case blue = "Blue"
    case green = "Green"
    case yellow = "Yellow"
    case black = "Black"
    case white = "White"
    case gray = "Gray"
    case neutral = "Neutral"
    
    var color: Color {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        case .black: return .black
        case .white: return .white
        case .gray: return .gray
        case .neutral: return Color(red: 0.9, green: 0.9, blue: 0.85)
        }
    }
}

struct Outfit: Codable, Equatable {
    var top: ClothingItem?
    var bottom: ClothingItem?
    var shoes: ClothingItem?
    var outerwear: ClothingItem?
    var accessories: [ClothingItem]
    
    init(top: ClothingItem? = nil,
         bottom: ClothingItem? = nil,
         shoes: ClothingItem? = nil,
         outerwear: ClothingItem? = nil,
         accessories: [ClothingItem] = []) {
        self.top = top
        self.bottom = bottom
        self.shoes = shoes
        self.outerwear = outerwear
        self.accessories = accessories
    }
}

// MARK: - Study Partner Preferences
struct StudyPartnerPreferences: Codable, Equatable {
    var preferredGender: Gender?
    var ageRange: ClosedRange<Int>
    var preferredAppearance: AppearancePreferences
    var matchingEnabled: Bool
    
    init(preferredGender: Gender? = nil,
         ageRange: ClosedRange<Int> = 18...25,
         preferredAppearance: AppearancePreferences = AppearancePreferences(),
         matchingEnabled: Bool = false) {
        self.preferredGender = preferredGender
        self.ageRange = ageRange
        self.preferredAppearance = preferredAppearance
        self.matchingEnabled = matchingEnabled
    }
}

struct AppearancePreferences: Codable, Equatable {
    var hairStyles: [HairStyle]
    var bodyTypes: [BodyType]
    var heights: [Height]
    
    init(hairStyles: [HairStyle] = [],
         bodyTypes: [BodyType] = [],
         heights: [Height] = []) {
        self.hairStyles = hairStyles
        self.bodyTypes = bodyTypes
        self.heights = heights
    }
}

// MARK: - Clothing Collections
struct ClothingCollection: Identifiable {
    let id: UUID
    let name: String
    let description: String
    let items: [ClothingItem]
    let price: Double
    let isPurchased: Bool
    
    init(id: UUID = UUID(),
         name: String,
         description: String,
         items: [ClothingItem],
         price: Double,
         isPurchased: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.items = items
        self.price = price
        self.isPurchased = isPurchased
    }
    
    // Predefined collections
    static let fallCollection = ClothingCollection(
        name: "Fall Collection",
        description: "Cozy autumn outfits for campus",
        items: [
            ClothingItem(name: "Fall Sweater", category: .top, isPremium: true, price: 1.99, collectionName: "Fall", color: .red),
            ClothingItem(name: "Plaid Shirt", category: .top, isPremium: true, price: 1.99, collectionName: "Fall", color: .neutral),
            ClothingItem(name: "Corduroy Pants", category: .bottom, isPremium: true, price: 1.99, collectionName: "Fall", color: .neutral),
            ClothingItem(name: "Ankle Boots", category: .shoes, isPremium: true, price: 1.99, collectionName: "Fall", color: .neutral),
            ClothingItem(name: "Scarf", category: .accessories, isPremium: true, price: 0.99, collectionName: "Fall", color: .red)
        ],
        price: 4.99
    )
    
    static let professionalCollection = ClothingCollection(
        name: "Professional",
        description: "Business casual for presentations",
        items: [
            ClothingItem(name: "Blazer", category: .outerwear, isPremium: true, price: 2.99, collectionName: "Professional", color: .black),
            ClothingItem(name: "Button-up Shirt", category: .top, isPremium: true, price: 1.99, collectionName: "Professional", color: .white),
            ClothingItem(name: "Dress Pants", category: .bottom, isPremium: true, price: 2.99, collectionName: "Professional", color: .black),
            ClothingItem(name: "Oxford Shoes", category: .shoes, isPremium: true, price: 2.99, collectionName: "Professional", color: .black),
            ClothingItem(name: "Tie", category: .accessories, isPremium: true, price: 0.99, collectionName: "Professional", color: .blue)
        ],
        price: 7.99
    )
    
    static let athleticCollection = ClothingCollection(
        name: "Athletic Wear",
        description: "Perfect for gym or active study breaks",
        items: [
            ClothingItem(name: "Sport Tank", category: .top, isPremium: true, price: 1.99, collectionName: "Athletic", color: .blue),
            ClothingItem(name: "Track Jacket", category: .outerwear, isPremium: true, price: 2.99, collectionName: "Athletic", color: .blue),
            ClothingItem(name: "Athletic Shorts", category: .bottom, isPremium: true, price: 1.99, collectionName: "Athletic", color: .black),
            ClothingItem(name: "Running Shoes", category: .shoes, isPremium: true, price: 2.99, collectionName: "Athletic", color: .white),
            ClothingItem(name: "Sweatband", category: .accessories, isPremium: true, price: 0.99, collectionName: "Athletic", color: .red)
        ],
        price: 6.99
    )
    
    static let collegeCollection = ClothingCollection(
        name: "College Pride",
        description: "Show your school spirit",
        items: [
            ClothingItem(name: "University Hoodie", category: .outerwear, isPremium: true, price: 2.99, collectionName: "College", color: .blue),
            ClothingItem(name: "School Jersey", category: .top, isPremium: true, price: 2.99, collectionName: "College", color: .blue),
            ClothingItem(name: "Campus Joggers", category: .bottom, isPremium: true, price: 1.99, collectionName: "College", color: .gray),
            ClothingItem(name: "Baseball Cap", category: .accessories, isPremium: true, price: 0.99, collectionName: "College", color: .blue),
            ClothingItem(name: "Backpack", category: .accessories, isPremium: true, price: 1.99, collectionName: "College", color: .blue)
        ],
        price: 6.99
    )
    
    static let allCollections: [ClothingCollection] = [
        fallCollection,
        professionalCollection,
        athleticCollection,
        collegeCollection
    ]
}
