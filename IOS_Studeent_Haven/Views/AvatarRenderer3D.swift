//
//  AvatarRenderer3D.swift
//  IOS_Student_Haven
//
//  3D avatar renderer with ARKit TrueDepth, Vision, and procedural fallbacks
//

import SwiftUI
import SceneKit
import ARKit

struct AvatarRenderer3D: UIViewRepresentable {
    let avatar: Avatar
    var cameraDistance: Float = 2.0
    var allowsRotation: Bool = true
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = .clear
        sceneView.allowsCameraControl = allowsRotation
        sceneView.autoenablesDefaultLighting = false
        sceneView.antialiasingMode = .multisampling4X
        
        // Create scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0.2, z: cameraDistance)
        cameraNode.look(at: SCNVector3(0, 0.2, 0))
        scene.rootNode.addChildNode(cameraNode)
        
        // Setup lighting
        setupLighting(scene: scene)
        
        // Load avatar with priority: TrueDepth → Vision → Procedural
        loadAvatar(into: scene, context: context)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        guard let scene = uiView.scene else { return }
        
        // Remove existing avatar
        scene.rootNode.childNode(withName: "avatar", recursively: false)?.removeFromParentNode()
        scene.rootNode.childNode(withName: "truedepth_face", recursively: false)?.removeFromParentNode()
        scene.rootNode.childNode(withName: "vision_face", recursively: false)?.removeFromParentNode()
        
        // Load avatar with priority: TrueDepth → Vision → Procedural
        loadAvatar(into: scene, context: context)
    }
    
    // MARK: - Avatar Loading
    
    private func loadAvatar(into scene: SCNScene, context: Context) {
        // Priority 1: Pre-made asset library model (best quality)
        if avatar.hasAssetSelected {
            loadAssetAvatar(into: scene, context: context)
        }
        // Priority 2: ARKit TrueDepth scan
        else if #available(iOS 13.0, *), avatar.hasTrueDepthScan {
            loadTrueDepthAvatar(into: scene, context: context)
        }
        // Priority 3: Vision framework scan
        else if avatar.hasVisionScan, let photoData = avatar.facePhotoData, let photo = UIImage(data: photoData) {
            loadVisionAvatar(into: scene, photo: photo, context: context)
        }
        // Priority 4: Procedural avatar (fallback)
        else {
            loadProceduralAvatar(into: scene, context: context)
        }
    }
    
    // MARK: - Asset Library
    
    private func loadAssetAvatar(into scene: SCNScene, context: Context) {
        guard let assetId = avatar.selectedAssetId,
              let asset = AvatarAsset.byId(assetId) else {
            print("Asset not found, falling back to procedural")
            loadProceduralAvatar(into: scene, context: context)
            return
        }
        
        let loader = AvatarAssetLoader.shared
        
        // Load the 3D model
        guard let avatarNode = loader.loadModel(for: asset) else {
            print("Failed to load asset model, falling back to procedural")
            loadProceduralAvatar(into: scene, context: context)
            return
        }
        
        // Apply customizations (skin tone, hair color, outfit)
        loader.applyCustomizations(
            to: avatarNode,
            skinTone: avatar.appearance.skinTone,
            hairColor: avatar.appearance.hairColor,
            outfit: avatar.currentOutfit
        )
        
        avatarNode.name = "asset_avatar"
        scene.rootNode.addChildNode(avatarNode)
    }
    
    @available(iOS 13.0, *)
    private func loadTrueDepthAvatar(into scene: SCNScene, context: Context) {
        // For now, we'll regenerate from photo since ARFaceGeometry serialization is complex
        // In production, you'd properly serialize/deserialize ARFaceGeometry vertex/index data
        
        if let photoData = avatar.arFacePhotoData, let photo = UIImage(data: photoData) {
            // Show photo-based preview for now
            // TODO: Implement full ARFaceGeometry deserialization and rendering
            print("TrueDepth avatar detected - showing photo preview")
            
            // Fallback to Vision for now
            if let visionPhoto = avatar.facePhotoData.flatMap({ UIImage(data: $0) }) ?? (avatar.arFacePhotoData.flatMap({ UIImage(data: $0) })) {
                loadVisionAvatar(into: scene, photo: visionPhoto, context: context)
            } else {
                loadProceduralAvatar(into: scene, context: context)
            }
        } else {
            // No photo, fallback to procedural
            loadProceduralAvatar(into: scene, context: context)
        }
    }
    
    private func loadVisionAvatar(into scene: SCNScene, photo: UIImage, context: Context) {
        VisionFaceCaptureService.shared.detectFace(in: photo) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let analysis):
                    if #available(iOS 17.0, *) {
                        let faceNode = ARFaceMeshBuilder.shared.buildFaceMesh(
                            from: analysis,
                            skinTone: self.avatar.appearance.skinTone
                        )
                        scene.rootNode.addChildNode(faceNode)
                        
                        if context.coordinator.shouldAnimate {
                            self.addIdleAnimation(to: faceNode)
                        }
                    } else {
                        // Fallback for iOS < 17
                        let fallbackNode = Custom3DAvatarBuilder.buildAvatar(from: self.avatar)
                        scene.rootNode.addChildNode(fallbackNode)
                    }
                case .failure(let error):
                    print("Failed to generate face mesh: \(error.localizedDescription)")
                    // Fallback to procedural avatar
                    self.loadProceduralAvatar(into: scene, context: context)
                }
            }
        }
    }
    
    private func loadProceduralAvatar(into scene: SCNScene, context: Context) {
        let avatarNode = Custom3DAvatarBuilder.buildAvatar(from: avatar)
        scene.rootNode.addChildNode(avatarNode)
        
        if context.coordinator.shouldAnimate {
            addIdleAnimation(to: avatarNode)
        }
    }
    
    private func setupLighting(scene: SCNScene) {
        // Key light (main light from front-top) - simulates sun/studio lighting
        let keyLight = SCNNode()
        keyLight.light = SCNLight()
        keyLight.light?.type = .directional
        keyLight.light?.color = UIColor(white: 1.0, alpha: 1.0)
        keyLight.light?.intensity = 1200
        keyLight.light?.castsShadow = true
        keyLight.light?.shadowMode = .deferred
        keyLight.light?.shadowColor = UIColor.black.withAlphaComponent(0.4)
        keyLight.position = SCNVector3(x: 2, y: 4, z: 3)
        keyLight.look(at: SCNVector3(x: 0, y: 0.2, z: 0))
        scene.rootNode.addChildNode(keyLight)
        
        // Fill light (softer, opposite side) - reduces harsh shadows
        let fillLight = SCNNode()
        fillLight.light = SCNLight()
        fillLight.light?.type = .omni
        fillLight.light?.color = UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0)  // Slightly cool
        fillLight.light?.intensity = 500
        fillLight.position = SCNVector3(x: -2.5, y: 1, z: 2)
        scene.rootNode.addChildNode(fillLight)
        
        // Back light (rim lighting) - creates depth
        let backLight = SCNNode()
        backLight.light = SCNLight()
        backLight.light?.type = .spot
        backLight.light?.color = UIColor(red: 1.0, green: 0.98, blue: 0.95, alpha: 1.0)  // Warm
        backLight.light?.intensity = 400
        backLight.light?.spotInnerAngle = 30
        backLight.light?.spotOuterAngle = 60
        backLight.position = SCNVector3(x: 0, y: 2, z: -3)
        backLight.look(at: SCNVector3(x: 0, y: 0.3, z: 0))
        scene.rootNode.addChildNode(backLight)
        
        // Ambient light (soft overall illumination)
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.45, alpha: 1.0)
        ambientLight.light?.intensity = 250
        scene.rootNode.addChildNode(ambientLight)
        
        // Add HDR environment for realistic reflections
        scene.lightingEnvironment.contents = UIColor(white: 0.85, alpha: 1.0)
        scene.lightingEnvironment.intensity = 0.8
    }
    

    
    private func addIdleAnimation(to node: SCNNode) {
        // Subtle breathing animation
        let breathe = CAKeyframeAnimation(keyPath: "scale.y")
        breathe.values = [1.0, 1.02, 1.0]
        breathe.keyTimes = [0, 0.5, 1]
        breathe.duration = 3.0
        breathe.repeatCount = .infinity
        node.addAnimation(breathe, forKey: "breathe")
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var shouldAnimate = true
    }
}

// MARK: - Preview Placeholder

struct AvatarPlaceholder3D: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("No Avatar")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                
                Text("Create your 3D avatar")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

// MARK: - Loading View

struct AvatarLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.2))
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.blue)
                
                Text("Loading Avatar...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
