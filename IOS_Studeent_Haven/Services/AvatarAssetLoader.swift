//
//  AvatarAssetLoader.swift
//  IOS_Student_Haven
//
//  Service to load pre-made 3D avatar models from app bundle
//

import Foundation
import SceneKit

class AvatarAssetLoader {
    static let shared = AvatarAssetLoader()
    
    private init() {}
    
    /// Load a 3D model from the app bundle
    func loadModel(for asset: AvatarAsset) -> SCNNode? {
        // Strip .dae extension from filename
        let baseFileName = asset.modelFileName.replacingOccurrences(of: ".dae", with: "")
        
        // Try root of bundle first
        var modelURL = Bundle.main.url(forResource: baseFileName, withExtension: "dae")
        
        // If not found, try in Assets/AvatarModels subdirectory
        if modelURL == nil {
            modelURL = Bundle.main.url(forResource: baseFileName, withExtension: "dae", subdirectory: "Assets/AvatarModels")
        }
        
        guard let modelURL = modelURL else {
            print("❌ Could not find DAE model file: \(asset.modelFileName)")
            print("   Bundle path: \(Bundle.main.bundlePath)")
            return createPlaceholderAvatar(for: asset)
        }
        
        print("✅ Loading DAE model from: \(modelURL.path)")
        
        do {
            print("🔄 Attempting to load scene from URL: \(modelURL.path)")
            
            let scene = try SCNScene(url: modelURL, options: [
                .checkConsistency: true,
                .flattenScene: false,
                .createNormalsIfAbsent: true
            ])
            
            print("✅ Scene loaded successfully")
            print("   Root node children count: \(scene.rootNode.childNodes.count)")
            
            let modelNode = SCNNode()
            modelNode.name = "asset_\(asset.id)"
            
            for child in scene.rootNode.childNodes {
                print("   - Child node: \(child.name ?? "unnamed"), geometry: \(child.geometry != nil)")
                modelNode.addChildNode(child)
            }
            
            if modelNode.childNodes.isEmpty {
                print("⚠️  No child nodes found in scene, using root node directly")
                let rootCopy = scene.rootNode.clone()
                return rootCopy
            }
            
            // Scale to consistent size (avatars should be ~1.7m tall)
            normalizeScale(node: modelNode)
            
            // Center at origin
            centerNode(modelNode)
            
            // Apply colors to materials
            applyColors(to: modelNode, asset: asset)
            
            print("✅ Model loaded and prepared successfully")
            return modelNode
            
        } catch {
            print("❌ Failed to load GLB model: \(error)")
            print("   Error details: \(error.localizedDescription)")
            return createPlaceholderAvatar(for: asset)
        }
    }
    
    /// Normalize avatar scale to consistent height
    private func normalizeScale(node: SCNNode) {
        let (min, max) = node.boundingBox
        let height = max.y - min.y
        
        // Target height of 1.7 units (representing ~1.7m tall person)
        let targetHeight: Float = 1.7
        let scale = targetHeight / height
        
        node.scale = SCNVector3(scale, scale, scale)
    }
    
    /// Center node at origin
    private func centerNode(_ node: SCNNode) {
        let (min, max) = node.boundingBox
        let center = SCNVector3(
            (min.x + max.x) / 2,
            min.y, // Keep feet on ground
            (min.z + max.z) / 2
        )
        
        node.position = SCNVector3(-center.x, -center.y, -center.z)
    }
    
    /// Apply colors to model materials based on asset properties
    private func applyColors(to node: SCNNode, asset: AvatarAsset) {
        // Get base colors
        let skinColor = asset.defaultSkinTone.uiColor
        let hairColor = asset.defaultHairColor.uiColor
        
        // Define clothing colors based on gender
        let primaryClothingColor: UIColor
        let secondaryClothingColor: UIColor
        
        switch asset.gender {
        case .male:
            primaryClothingColor = UIColor(red: 0.2, green: 0.4, blue: 0.7, alpha: 1.0) // Blue
            secondaryClothingColor = UIColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0) // Dark gray
        case .female:
            primaryClothingColor = UIColor(red: 0.8, green: 0.3, blue: 0.5, alpha: 1.0) // Pink/Magenta
            secondaryClothingColor = UIColor(red: 0.5, green: 0.2, blue: 0.6, alpha: 1.0) // Purple
        case .other:
            primaryClothingColor = UIColor(red: 0.5, green: 0.7, blue: 0.4, alpha: 1.0) // Green
            secondaryClothingColor = UIColor(red: 0.7, green: 0.5, blue: 0.3, alpha: 1.0) // Orange
        }
        
        // Recursively apply colors to all geometry
        applyColorsRecursive(node: node, skinColor: skinColor, hairColor: hairColor, 
                           primaryClothing: primaryClothingColor, 
                           secondaryClothing: secondaryClothingColor)
    }
    
    /// Recursively apply colors to node materials
    private func applyColorsRecursive(node: SCNNode, skinColor: UIColor, hairColor: UIColor,
                                     primaryClothing: UIColor, secondaryClothing: UIColor) {
        // Apply materials to current node's geometry
        if let geometry = node.geometry {
            for material in geometry.materials {
                // Try to determine material type from name
                let materialName = material.name?.lowercased() ?? ""
                
                if materialName.contains("skin") || materialName.contains("body") || materialName.contains("face") || materialName.contains("hand") {
                    // Skin material
                    material.diffuse.contents = skinColor
                    material.lightingModel = .physicallyBased
                    material.roughness.contents = 0.8
                } else if materialName.contains("hair") || materialName.contains("eyebrow") {
                    // Hair material
                    material.diffuse.contents = hairColor
                    material.lightingModel = .physicallyBased
                    material.roughness.contents = 0.6
                } else if materialName.contains("shirt") || materialName.contains("top") || materialName.contains("jacket") {
                    // Upper clothing
                    material.diffuse.contents = primaryClothing
                    material.lightingModel = .physicallyBased
                    material.roughness.contents = 0.7
                } else if materialName.contains("pant") || materialName.contains("shorts") || materialName.contains("skirt") || materialName.contains("bottom") {
                    // Lower clothing
                    material.diffuse.contents = secondaryClothing
                    material.lightingModel = .physicallyBased
                    material.roughness.contents = 0.7
                } else {
                    // Default: add subtle tinting to keep texture visible
                    if let currentColor = material.diffuse.contents as? UIColor {
                        // Keep existing color but ensure it's visible
                        material.lightingModel = .physicallyBased
                        material.roughness.contents = 0.7
                    } else {
                        // No existing color, apply clothing color
                        material.diffuse.contents = primaryClothing
                        material.lightingModel = .physicallyBased
                        material.roughness.contents = 0.7
                    }
                }
            }
        }
        
        // Recursively process child nodes
        for child in node.childNodes {
            applyColorsRecursive(node: child, skinColor: skinColor, hairColor: hairColor,
                               primaryClothing: primaryClothing, secondaryClothing: secondaryClothing)
        }
    }
    
    /// Create a placeholder avatar when model file is missing
    private func createPlaceholderAvatar(for asset: AvatarAsset) -> SCNNode {
        let avatarNode = SCNNode()
        avatarNode.name = "placeholder_\(asset.id)"
        
        // Create simple humanoid shape
        // Head
        let head = SCNSphere(radius: 0.12)
        head.firstMaterial?.diffuse.contents = asset.defaultSkinTone.uiColor
        let headNode = SCNNode(geometry: head)
        headNode.position = SCNVector3(0, 1.5, 0)
        avatarNode.addChildNode(headNode)
        
        // Body (torso)
        let torso = SCNCapsule(capRadius: 0.15, height: 0.6)
        torso.firstMaterial?.diffuse.contents = UIColor.systemBlue
        let torsoNode = SCNNode(geometry: torso)
        torsoNode.position = SCNVector3(0, 1.0, 0)
        avatarNode.addChildNode(torsoNode)
        
        // Arms
        for x in [-0.25, 0.25] as [Float] {
            let arm = SCNCapsule(capRadius: 0.04, height: 0.5)
            arm.firstMaterial?.diffuse.contents = asset.defaultSkinTone.uiColor
            let armNode = SCNNode(geometry: arm)
            armNode.position = SCNVector3(x, 0.95, 0)
            armNode.eulerAngles = SCNVector3(0, 0, x > 0 ? -Float.pi/12 : Float.pi/12)
            avatarNode.addChildNode(armNode)
        }
        
        // Legs
        for x in [-0.1, 0.1] as [Float] {
            let leg = SCNCapsule(capRadius: 0.06, height: 0.7)
            leg.firstMaterial?.diffuse.contents = UIColor.darkGray
            let legNode = SCNNode(geometry: leg)
            legNode.position = SCNVector3(x, 0.35, 0)
            avatarNode.addChildNode(legNode)
        }
        
        // Add label
        let text = SCNText(string: "Model Missing\n\(asset.name)", extrusionDepth: 0.01)
        text.font = UIFont.systemFont(ofSize: 0.08)
        text.firstMaterial?.diffuse.contents = UIColor.red
        let textNode = SCNNode(geometry: text)
        textNode.position = SCNVector3(-0.2, 0.3, 0)
        textNode.scale = SCNVector3(0.5, 0.5, 0.5)
        avatarNode.addChildNode(textNode)
        
        return avatarNode
    }
    
    /// Apply customizations (skin tone, hair color) to loaded model
    func applyCustomizations(to node: SCNNode, skinTone: SkinTone, hairColor: HairColor, outfit: Outfit) {
        // Find and update skin materials
        node.enumerateChildNodes { child, _ in
            guard let geometry = child.geometry else { return }
            
            for material in geometry.materials {
                // Look for materials with "skin" in their name
                if let name = material.name?.lowercased(),
                   name.contains("skin") || name.contains("body") || name.contains("face") {
                    material.diffuse.contents = skinTone.uiColor
                }
                
                // Look for materials with "hair" in their name
                if let name = material.name?.lowercased(),
                   name.contains("hair") {
                    material.diffuse.contents = hairColor.uiColor
                }
                
                // Apply clothing colors
                if let name = material.name?.lowercased() {
                    if name.contains("shirt") || name.contains("top"), let top = outfit.top {
                        material.diffuse.contents = top.color.uiColor
                    }
                    if name.contains("pants") || name.contains("bottom"), let bottom = outfit.bottom {
                        material.diffuse.contents = bottom.color.uiColor
                    }
                    if name.contains("shoe"), let shoes = outfit.shoes {
                        material.diffuse.contents = shoes.color.uiColor
                    }
                }
            }
        }
    }
}

// MARK: - Helper Extensions

extension SkinTone {
    var uiColor: UIColor {
        switch self {
        case .veryLight: return UIColor(red: 1.0, green: 0.95, blue: 0.91, alpha: 1.0)
        case .light: return UIColor(red: 0.98, green: 0.88, blue: 0.78, alpha: 1.0)
        case .medium: return UIColor(red: 0.93, green: 0.78, blue: 0.62, alpha: 1.0)
        case .tan: return UIColor(red: 0.82, green: 0.65, blue: 0.48, alpha: 1.0)
        case .dark: return UIColor(red: 0.65, green: 0.48, blue: 0.36, alpha: 1.0)
        case .veryDark: return UIColor(red: 0.45, green: 0.33, blue: 0.25, alpha: 1.0)
        }
    }
}

extension HairColor {
    var uiColor: UIColor {
        switch self {
        case .black: return UIColor.black
        case .brown: return UIColor(red: 0.4, green: 0.26, blue: 0.13, alpha: 1.0)
        case .blonde: return UIColor(red: 0.98, green: 0.94, blue: 0.75, alpha: 1.0)
        case .red: return UIColor(red: 0.72, green: 0.26, blue: 0.17, alpha: 1.0)
        case .gray: return UIColor.gray
        case .auburn: return UIColor(red: 0.65, green: 0.16, blue: 0.16, alpha: 1.0)
        }
    }
}

extension ClothingColor {
    var uiColor: UIColor {
        switch self {
        case .red: return UIColor.red
        case .blue: return UIColor.blue
        case .green: return UIColor.green
        case .yellow: return UIColor.yellow
        case .black: return UIColor.black
        case .white: return UIColor.white
        case .gray: return UIColor.gray
        case .neutral: return UIColor(red: 0.9, green: 0.9, blue: 0.85, alpha: 1)
        }
    }
}
