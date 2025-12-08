//
//  AvatarAssetPickerWithPreview.swift
//  IOS_Student_Haven
//
//  Avatar selector with 3D model previews
//

import SwiftUI
import SceneKit

struct AvatarAssetPickerWithPreview: View {
    @Binding var selectedAsset: AvatarAsset?
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory: AssetCategory = .all
    
    enum AssetCategory: String, CaseIterable {
        case all = "All"
        case male = "Male"
        case female = "Female"
    }
    
    var filteredAssets: [AvatarAsset] {
        var assets = AvatarAsset.library
        
        switch selectedCategory {
        case .all:
            break
        case .male:
            assets = assets.filter { $0.gender == .male }
        case .female:
            assets = assets.filter { $0.gender == .female }
        }
        
        return assets
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category picker
                Picker("Category", selection: $selectedCategory) {
                    ForEach(AssetCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Avatar grid with 3D previews
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(filteredAssets) { asset in
                            Avatar3DPreviewCard(
                                asset: asset,
                                isSelected: selectedAsset?.id == asset.id
                            ) {
                                selectedAsset = asset
                                dismiss()
                            }
                            .id(asset.id) // Help LazyVGrid track items
                        }
                    }
                    .padding()
                }
                .simultaneousGesture(DragGesture()) // Prevent touch conflicts
            }
            .navigationTitle("Choose Your Avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct Avatar3DPreviewCard: View {
    let asset: AvatarAsset
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                // 3D Model Preview
                Avatar3DPreviewView(asset: asset)
                    .frame(height: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.green : Color.clear, lineWidth: 3)
                    )
                
                // Asset info
                VStack(alignment: .leading, spacing: 4) {
                    Text(asset.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: bodyTypeIcon)
                            .font(.caption2)
                        Text(asset.bodyType.rawValue)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if isSelected {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Selected")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var bodyTypeIcon: String {
        switch asset.bodyType {
        case .slim: return "figure.walk"
        case .average: return "figure.stand"
        case .athletic: return "figure.run"
        case .heavy: return "figure.stand"
        }
    }
}

struct Avatar3DPreviewView: UIViewRepresentable {
    let asset: AvatarAsset
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = .clear
        sceneView.allowsCameraControl = false // Disable for better scroll
        sceneView.autoenablesDefaultLighting = true
        sceneView.antialiasingMode = .none // Faster rendering
        sceneView.rendersContinuously = false // Only render when needed
        
        // Create scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0.8, z: 2.5)
        cameraNode.look(at: SCNVector3(0, 0.8, 0))
        scene.rootNode.addChildNode(cameraNode)
        
        // Load model asynchronously to not block scrolling
        DispatchQueue.global(qos: .userInitiated).async {
            let loader = AvatarAssetLoader.shared
            if let modelNode = loader.loadModel(for: asset) {
                DispatchQueue.main.async {
                    modelNode.position = SCNVector3(0, 0, 0)
                    scene.rootNode.addChildNode(modelNode)
                    
                    // Add rotation animation
                    let rotation = CABasicAnimation(keyPath: "rotation")
                    rotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
                    rotation.duration = 10
                    rotation.repeatCount = .infinity
                    modelNode.addAnimation(rotation, forKey: "rotation")
                }
            }
        }
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // No updates needed
    }
}

#Preview {
    AvatarAssetPickerWithPreview(selectedAsset: .constant(nil))
}
