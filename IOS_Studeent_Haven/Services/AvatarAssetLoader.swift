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
        guard let modelURL = Bundle.main.url(forResource: asset.modelFileName.replacingOccurrences(of: ".glb", with: ""), 
                                              withExtension: "glb", 
                                              subdirectory: "Assets/AvatarModels") else {
            print("Could not find model file: \(asset.modelFileName)")
            return createPlaceholderAvatar(for: asset)
        }
        
        do {
            let scene = try SCNScene(url: modelURL, options: [
                .checkConsistency: true,
                .flattenScene: false,
                .createNormalsIfAbsent: true
            ])
            
            let modelNode = SCNNode()
            for child in scene.rootNode.childNodes {
                modelNode.addChildNode(child)
            }
            
            // Scale to consistent size (avatars should be ~1.7m tall)
            normalizeScale(node: modelNode)
            
            // Center at origin
            centerNode(modelNode)
            
            return modelNode
            
        } catch {
            print("Failed to load GLB model: \(error)")
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
