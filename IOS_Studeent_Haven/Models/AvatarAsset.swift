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
            name: "Remy",
            gender: .male,
            ethnicity: .caucasian,
            bodyType: .average,
            modelFileName: "male_casual_1.dae",
            thumbnailName: "male_casual_1_thumb",
            defaultSkinTone: .light,
            defaultHairColor: .brown,
            defaultHairStyle: .short
        ),
        AvatarAsset(
            id: "male_athletic_1",
            name: "The Boss",
            gender: .male,
            ethnicity: .caucasian,
            bodyType: .athletic,
            modelFileName: "male_athletic_1.dae",
            thumbnailName: "male_athletic_1_thumb",
            defaultSkinTone: .tan,
            defaultHairColor: .brown,
            defaultHairStyle: .short
        ),
        AvatarAsset(
            id: "male_slim_1",
            name: "Big Vegas",
            gender: .male,
            ethnicity: .caucasian,
            bodyType: .slim,
            modelFileName: "male_slim_1.dae",
            thumbnailName: "male_slim_1_thumb",
            defaultSkinTone: .light,
            defaultHairColor: .brown,
            defaultHairStyle: .medium
        ),
        AvatarAsset(
            id: "male_casual_2",
            name: "Aj",
            gender: .male,
            ethnicity: .african,
            bodyType: .average,
            modelFileName: "male_casual_2.dae",
            thumbnailName: "male_casual_2_thumb",
            defaultSkinTone: .dark,
            defaultHairColor: .black,
            defaultHairStyle: .short
        ),
        // Female avatars
        AvatarAsset(
            id: "female_casual_1",
            name: "Medea",
            gender: .female,
            ethnicity: .caucasian,
            bodyType: .average,
            modelFileName: "female_casual_1.dae",
            thumbnailName: "female_casual_1_thumb",
            defaultSkinTone: .light,
            defaultHairColor: .brown,
            defaultHairStyle: .long
        ),
        AvatarAsset(
            id: "female_athletic_1",
            name: "Arissa",
            gender: .female,
            ethnicity: .african,
            bodyType: .athletic,
            modelFileName: "female_athletic_1.dae",
            thumbnailName: "female_athletic_1_thumb",
            defaultSkinTone: .dark,
            defaultHairColor: .black,
            defaultHairStyle: .curly
        ),
        AvatarAsset(
            id: "female_slim_1",
            name: "Erika",
            gender: .female,
            ethnicity: .caucasian,
            bodyType: .slim,
            modelFileName: "female_slim_1.dae",
            thumbnailName: "female_slim_1_thumb",
            defaultSkinTone: .light,
            defaultHairColor: .brown,
            defaultHairStyle: .long
        ),
        AvatarAsset(
            id: "female_casual_2",
            name: "Girlscout",
            gender: .female,
            ethnicity: .caucasian,
            bodyType: .average,
            modelFileName: "female_casual_2.dae",
            thumbnailName: "female_casual_2_thumb",
            defaultSkinTone: .light,
            defaultHairColor: .brown,
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
