//
//  AvatarAsset.swift
//  IOS_Student_Haven
//
//  Pre-made 3D avatar asset library for offline avatar selection
//

import Foundation

/// Represents a pre-made 3D avatar asset
struct AvatarAsset: Identifiable, Codable {
    let id: String
    let name: String
    let gender: Gender
    let ethnicity: Ethnicity
    let bodyType: BodyType
    let modelFileName: String  // GLB file in app bundle
    let thumbnailName: String  // Preview image
    let defaultSkinTone: SkinTone
    let defaultHairColor: HairColor
    let defaultHairStyle: HairStyle
    
    /// All available avatar assets
    static let library: [AvatarAsset] = [
        // Male avatars
        AvatarAsset(
            id: "male_casual_1",
            name: "Alex",
            gender: .male,
            ethnicity: .caucasian,
            bodyType: .average,
            modelFileName: "male_casual_1.glb",
            thumbnailName: "male_casual_1_thumb",
            defaultSkinTone: .light,
            defaultHairColor: .brown,
            defaultHairStyle: .short
        ),
        AvatarAsset(
            id: "male_athletic_1",
            name: "Marcus",
            gender: .male,
            ethnicity: .african,
            bodyType: .athletic,
            modelFileName: "male_athletic_1.glb",
            thumbnailName: "male_athletic_1_thumb",
            defaultSkinTone: .dark,
            defaultHairColor: .black,
            defaultHairStyle: .short
        ),
        AvatarAsset(
            id: "male_slim_1",
            name: "Kenji",
            gender: .male,
            ethnicity: .asian,
            bodyType: .slim,
            modelFileName: "male_slim_1.glb",
            thumbnailName: "male_slim_1_thumb",
            defaultSkinTone: .medium,
            defaultHairColor: .black,
            defaultHairStyle: .medium
        ),
        AvatarAsset(
            id: "male_casual_2",
            name: "Diego",
            gender: .male,
            ethnicity: .latino,
            bodyType: .average,
            modelFileName: "male_casual_2.glb",
            thumbnailName: "male_casual_2_thumb",
            defaultSkinTone: .tan,
            defaultHairColor: .black,
            defaultHairStyle: .short
        ),
        AvatarAsset(
            id: "male_formal_1",
            name: "James",
            gender: .male,
            ethnicity: .caucasian,
            bodyType: .average,
            modelFileName: "male_formal_1.glb",
            thumbnailName: "male_formal_1_thumb",
            defaultSkinTone: .veryLight,
            defaultHairColor: .blonde,
            defaultHairStyle: .short
        ),
        
        // Female avatars
        AvatarAsset(
            id: "female_casual_1",
            name: "Emma",
            gender: .female,
            ethnicity: .caucasian,
            bodyType: .average,
            modelFileName: "female_casual_1.glb",
            thumbnailName: "female_casual_1_thumb",
            defaultSkinTone: .light,
            defaultHairColor: .blonde,
            defaultHairStyle: .long
        ),
        AvatarAsset(
            id: "female_athletic_1",
            name: "Jasmine",
            gender: .female,
            ethnicity: .african,
            bodyType: .athletic,
            modelFileName: "female_athletic_1.glb",
            thumbnailName: "female_athletic_1_thumb",
            defaultSkinTone: .dark,
            defaultHairColor: .black,
            defaultHairStyle: .curly
        ),
        AvatarAsset(
            id: "female_slim_1",
            name: "Mei",
            gender: .female,
            ethnicity: .asian,
            bodyType: .slim,
            modelFileName: "female_slim_1.glb",
            thumbnailName: "female_slim_1_thumb",
            defaultSkinTone: .medium,
            defaultHairColor: .black,
            defaultHairStyle: .long
        ),
        AvatarAsset(
            id: "female_casual_2",
            name: "Sofia",
            gender: .female,
            ethnicity: .latino,
            bodyType: .average,
            modelFileName: "female_casual_2.glb",
            thumbnailName: "female_casual_2_thumb",
            defaultSkinTone: .tan,
            defaultHairColor: .brown,
            defaultHairStyle: .medium
        ),
        AvatarAsset(
            id: "female_formal_1",
            name: "Olivia",
            gender: .female,
            ethnicity: .caucasian,
            bodyType: .average,
            modelFileName: "female_formal_1.glb",
            thumbnailName: "female_formal_1_thumb",
            defaultSkinTone: .veryLight,
            defaultHairColor: .red,
            defaultHairStyle: .long
        ),
        
        // Non-binary/other avatars
        AvatarAsset(
            id: "neutral_casual_1",
            name: "Jordan",
            gender: .other,
            ethnicity: .caucasian,
            bodyType: .slim,
            modelFileName: "neutral_casual_1.glb",
            thumbnailName: "neutral_casual_1_thumb",
            defaultSkinTone: .light,
            defaultHairColor: .brown,
            defaultHairStyle: .short
        ),
        AvatarAsset(
            id: "neutral_casual_2",
            name: "Riley",
            gender: .other,
            ethnicity: .mixed,
            bodyType: .average,
            modelFileName: "neutral_casual_2.glb",
            thumbnailName: "neutral_casual_2_thumb",
            defaultSkinTone: .tan,
            defaultHairColor: .black,
            defaultHairStyle: .medium
        ),
    ]
    
    /// Filter avatars by gender
    static func byGender(_ gender: Gender) -> [AvatarAsset] {
        library.filter { $0.gender == gender }
    }
    
    /// Filter avatars by body type
    static func byBodyType(_ bodyType: BodyType) -> [AvatarAsset] {
        library.filter { $0.bodyType == bodyType }
    }
    
    /// Get asset by ID
    static func byId(_ id: String) -> AvatarAsset? {
        library.first { $0.id == id }
    }
}

enum Ethnicity: String, Codable, CaseIterable {
    case caucasian = "Caucasian"
    case african = "African"
    case asian = "Asian"
    case latino = "Latino"
    case middleEastern = "Middle Eastern"
    case mixed = "Mixed"
}
