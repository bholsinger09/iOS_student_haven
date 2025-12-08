//
//  SimplifiedAvatarCreatorView.swift
//  IOS_Student_Haven
//
//  Simplified avatar creation - just select from pre-made assets
//

import SwiftUI
import SceneKit

struct SimplifiedAvatarCreatorView: View {
    @ObservedObject var viewModel: AvatarViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var avatarName = ""
    @State private var selectedAsset: AvatarAsset?
    @State private var showAssetPicker = false
    @State private var currentStep = 0
    
    let steps = ["Select Avatar", "Name"]
    
    init(viewModel: AvatarViewModel) {
        self.viewModel = viewModel
        
        // Pre-populate from existing avatar if editing
        if let avatar = viewModel.myAvatar {
            _avatarName = State(initialValue: avatar.name)
            if let assetId = avatar.selectedAssetId,
               let asset = AvatarAsset.byId(assetId) {
                _selectedAsset = State(initialValue: asset)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        VStack(spacing: 4) {
                            Circle()
                                .fill(index <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Text("\(index + 1)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                )
                            Text(steps[index])
                                .font(.caption2)
                                .foregroundColor(index <= currentStep ? .primary : .secondary)
                        }
                        
                        if index < steps.count - 1 {
                            Rectangle()
                                .fill(index < currentStep ? Color.blue : Color.gray.opacity(0.3))
                                .frame(height: 2)
                        }
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Step content
                        switch currentStep {
                        case 0:
                            assetSelectionStep
                        case 1:
                            nameStep
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }
                
                // Navigation buttons
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                    
                    if currentStep < steps.count - 1 {
                        Button("Next") {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedAsset == nil)
                    } else {
                        Button("Create Avatar") {
                            createAvatar()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(avatarName.isEmpty || selectedAsset == nil)
                    }
                }
                .padding()
            }
            .navigationTitle("Create Your Avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showAssetPicker) {
                AvatarAssetPickerWithPreview(selectedAsset: $selectedAsset)
            }
            .onAppear {
                // Load existing avatar data if editing
                if let avatar = viewModel.myAvatar {
                    avatarName = avatar.name
                    if let assetId = avatar.selectedAssetId,
                       let asset = AvatarAsset.byId(assetId) {
                        selectedAsset = asset
                    }
                }
            }
        }
    }
    
    // MARK: - Steps
    
    private var assetSelectionStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Choose Your Avatar")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Select from professional 3D models")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Show selected avatar or picker button
            if let asset = selectedAsset {
                SelectedAvatarCard(asset: asset, onTap: {
                    showAssetPicker = true
                })
                .id(asset.id) // Force refresh when asset changes
            } else {
                Button(action: {
                    showAssetPicker = true
                }) {
                    VStack(spacing: 16) {
                        Image(systemName: "person.3.sequence.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Choose Your Avatar")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("Browse available models")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [5]))
                    )
                }
            }
            
            Spacer()
        }
    }
    
    private var nameStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Name Your Avatar")
                .font(.title2)
                .fontWeight(.bold)
            
            TextField("Enter a name", text: $avatarName)
                .textFieldStyle(.roundedBorder)
                .font(.title3)
                .padding(.vertical, 8)
            
            if let asset = selectedAsset {
                VStack(spacing: 16) {
                    Divider()
                    
                    Text("Selected Avatar")
                        .font(.headline)
                    
                    SelectedAvatarCard(asset: asset, showChangeButton: false) {}
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Actions
    
    private func createAvatar() {
        guard let asset = selectedAsset else { return }
        
        let newAvatar = Avatar(
            name: avatarName,
            gender: asset.gender,
            age: 25,
            appearance: Appearance(
                skinTone: asset.defaultSkinTone,
                hairStyle: asset.defaultHairStyle,
                hairColor: asset.defaultHairColor
            )
        )
        
        var avatar = newAvatar
        avatar.selectedAssetId = asset.id
        
        viewModel.updateAvatar(avatar)
        dismiss()
    }
}

// MARK: - Supporting Views

struct SelectedAvatarCard: View {
    let asset: AvatarAsset
    var showChangeButton: Bool = true
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // 3D Model Preview
                Avatar3DPreviewViewLarge(asset: asset)
                    .frame(height: 250)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(asset.name)
                            .font(.headline)
                        
                        HStack(spacing: 8) {
                            Label(asset.bodyType.rawValue, systemImage: bodyTypeIcon)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Label(asset.ethnicity.rawValue, systemImage: "globe")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if showChangeButton {
                        Text("Change")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.green, lineWidth: 2)
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

struct Avatar3DPreviewViewLarge: UIViewRepresentable {
    let asset: AvatarAsset
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = .clear
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.antialiasingMode = .multisampling2X // Balance quality/performance
        
        // Create scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0.8, z: 2.5)
        cameraNode.look(at: SCNVector3(0, 0.8, 0))
        scene.rootNode.addChildNode(cameraNode)
        
        // Load model
        let loader = AvatarAssetLoader.shared
        if let modelNode = loader.loadModel(for: asset) {
            modelNode.position = SCNVector3(0, 0, 0)
            scene.rootNode.addChildNode(modelNode)
            
            // Add rotation animation
            let rotation = CABasicAnimation(keyPath: "rotation")
            rotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
            rotation.duration = 10
            rotation.repeatCount = .infinity
            modelNode.addAnimation(rotation, forKey: "rotation")
        }
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Check if we need to update the model
        guard let scene = uiView.scene else { return }
        
        // Remove old model nodes (keep camera)
        let modelNodes = scene.rootNode.childNodes.filter { $0.camera == nil }
        modelNodes.forEach { $0.removeFromParentNode() }
        
        // Load new model
        let loader = AvatarAssetLoader.shared
        if let modelNode = loader.loadModel(for: asset) {
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

#Preview {
    SimplifiedAvatarCreatorView(viewModel: AvatarViewModel())
}
