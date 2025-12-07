//
//  AvatarCreatorView.swift
//  IOS_Student_Haven
//
//  Created on 12/7/24.
//

import SwiftUI
import ARKit

struct AvatarCreatorView: View {
    @StateObject private var viewModel = AvatarViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var avatarName = ""
    @State private var selectedGender: Gender = .other
    @State private var selectedAge: Int = 25
    @State private var appearance = Appearance()
    @State private var currentStep = 0
    @State private var useFaceScan = false
    @State private var capturedPhoto: UIImage?
    @State private var faceAnalysis: FaceAnalysis?
    @State private var showFaceCapture = false
    
    // ARKit TrueDepth support
    @State private var useTrueDepth = false
    @State private var showARScanner = false
    @State private var capturedARGeometry: ARFaceGeometry?
    @State private var capturedARPhoto: UIImage?
    
    // Pre-made asset library
    @State private var usePreMadeAsset = false
    @State private var showAssetPicker = false
    @State private var selectedAsset: AvatarAsset?
    
    let steps = ["Basic Info", "Face", "Hair", "Body"]
    
    // Check if device supports TrueDepth
    private var supportsTrueDepth: Bool {
        if #available(iOS 13.0, *) {
            return ARFaceTrackingConfiguration.isSupported
        }
        return false
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
                        // 3D Avatar preview
                        if !avatarName.isEmpty {
                            if let arPhoto = capturedARPhoto, useTrueDepth, capturedARGeometry != nil {
                                // Show TrueDepth scan photo
                                ZStack {
                                    Image(uiImage: arPhoto)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 300)
                                        .cornerRadius(20)
                                    
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                            Text("TrueDepth 3D scan")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                        }
                                        .padding(8)
                                        .background(Color.black.opacity(0.6))
                                        .cornerRadius(8)
                                        .padding()
                                    }
                                }
                            } else if let photo = capturedPhoto, useFaceScan, !useTrueDepth {
                                // Show Vision scan photo
                                ZStack {
                                    Image(uiImage: photo)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 300)
                                        .cornerRadius(20)
                                    
                                    if faceAnalysis != nil {
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                                Text("Photo scanned")
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.white)
                                            }
                                            .padding(8)
                                            .background(Color.black.opacity(0.6))
                                            .cornerRadius(8)
                                            .padding()
                                        }
                                    }
                                }
                            } else if !useFaceScan {
                                // Show procedural preview
                                let previewAvatar = Avatar(
                                    name: avatarName,
                                    gender: selectedGender,
                                    age: selectedAge,
                                    appearance: appearance
                                )
                                AvatarRenderer3D(avatar: previewAvatar, allowsRotation: true)
                                    .frame(height: 300)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.black.opacity(0.05))
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                        }
                        
                        // Step content
                        switch currentStep {
                        case 0:
                            basicInfoStep
                        case 1:
                            faceStep
                        case 2:
                            hairStep
                        case 3:
                            bodyStep
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
                        .disabled(currentStep == 0 && avatarName.isEmpty)
                    } else {
                        Button("Create Avatar") {
                            createAvatar()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(avatarName.isEmpty)
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
            .sheet(isPresented: $showFaceCapture) {
                if useTrueDepth && supportsTrueDepth {
                    if #available(iOS 13.0, *) {
                        ARFaceScannerView(
                            capturedFaceGeometry: $capturedARGeometry,
                            capturedPhoto: $capturedARPhoto
                        )
                    } else {
                        FacePhotoCaptureView(capturedImage: $capturedPhoto, faceAnalysis: $faceAnalysis)
                    }
                } else {
                    FacePhotoCaptureView(capturedImage: $capturedPhoto, faceAnalysis: $faceAnalysis)
                }
            }
            .sheet(isPresented: $showARScanner) {
                if #available(iOS 13.0, *) {
                    ARFaceScannerView(
                        capturedFaceGeometry: $capturedARGeometry,
                        capturedPhoto: $capturedARPhoto
                    )
                }
            }
            .sheet(isPresented: $showAssetPicker) {
                AvatarAssetPickerView(
                    selectedAsset: $selectedAsset,
                    filterGender: selectedGender
                )
            }
        }
    }
    
    // MARK: - Steps
    private var basicInfoStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Let's start with the basics")
                .font(.title2)
                .fontWeight(.bold)
            
            // Avatar Type Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Avatar Type")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    // Pre-made Assets - BEST OPTION
                    Button(action: {
                        usePreMadeAsset = true
                        useFaceScan = false
                        useTrueDepth = false
                        showAssetPicker = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.3.sequence.fill")
                                .font(.title2)
                                .frame(width: 40)
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text("Choose Pre-made Avatar")
                                        .font(.headline)
                                    Image(systemName: "star.fill")
                                        .font(.caption2)
                                        .foregroundColor(.yellow)
                                    Text("BEST")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.yellow)
                                }
                                Text("Professional 3D models - photorealistic quality")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if usePreMadeAsset && selectedAsset != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(usePreMadeAsset ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(usePreMadeAsset ? Color.green.opacity(0.05) : Color.clear)
                                )
                        )
                        .foregroundColor(.primary)
                    }
                    
                    // Custom procedural avatar
                    Button(action: {
                        usePreMadeAsset = false
                        useFaceScan = false
                        useTrueDepth = false
                        capturedPhoto = nil
                        faceAnalysis = nil
                        capturedARGeometry = nil
                        capturedARPhoto = nil
                        selectedAsset = nil
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.fill")
                                .font(.title2)
                                .frame(width: 40)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Custom Avatar")
                                    .font(.headline)
                                Text("Build from scratch with customization")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if !useFaceScan && !useTrueDepth && !usePreMadeAsset {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(!useFaceScan && !useTrueDepth && !usePreMadeAsset ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                        )
                        .foregroundColor(.primary)
                    }
                    
                    // TrueDepth ARKit (iPhone X+)
                    if supportsTrueDepth {
                        Button(action: {
                            usePreMadeAsset = false
                            useFaceScan = true
                            useTrueDepth = true
                            selectedAsset = nil
                            showARScanner = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "face.dashed.fill")
                                    .font(.title2)
                                    .frame(width: 40)
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        Text("TrueDepth Scan")
                                            .font(.headline)
                                        Image(systemName: "star.fill")
                                            .font(.caption2)
                                            .foregroundColor(.yellow)
                                    }
                                    Text("Photorealistic 3D scan (50k+ vertices)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if useTrueDepth && capturedARGeometry != nil {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(useTrueDepth ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                            )
                            .foregroundColor(.primary)
                        }
                    }
                    
                    // Vision framework scan (fallback)
                    Button(action: {
                        usePreMadeAsset = false
                        useFaceScan = true
                        useTrueDepth = false
                        selectedAsset = nil
                        showFaceCapture = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "faceid")
                                .font(.title2)
                                .frame(width: 40)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Photo Scan")
                                    .font(.headline)
                                Text("2D face detection with Vision AI")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if useFaceScan && !useTrueDepth && faceAnalysis != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(useFaceScan && !useTrueDepth ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                        )
                        .foregroundColor(.primary)
                    }
                }
                
                // Status indicators
                if let geometry = capturedARGeometry, useTrueDepth {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("TrueDepth scan complete (\(geometry.vertices.count) vertices)")
                            .font(.subheadline)
                        Spacer()
                        Button("Rescan") {
                            showARScanner = true
                        }
                        .font(.subheadline)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green.opacity(0.1))
                    )
                } else if let analysis = faceAnalysis, useFaceScan && !useTrueDepth {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Photo scanned successfully")
                            .font(.subheadline)
                        Spacer()
                        Button("Rescan") {
                            showFaceCapture = true
                        }
                        .font(.subheadline)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green.opacity(0.1))
                    )
                } else if usePreMadeAsset, let asset = selectedAsset {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Selected: \(asset.name)")
                            .font(.subheadline)
                        Spacer()
                        Button("Change") {
                            showAssetPicker = true
                        }
                        .font(.subheadline)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green.opacity(0.1))
                    )
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Avatar Name")
                    .font(.headline)
                TextField("Enter a name", text: $avatarName)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Gender")
                    .font(.headline)
                Picker("Gender", selection: $selectedGender) {
                    ForEach(Gender.allCases, id: \.self) { gender in
                        Text(gender.rawValue).tag(gender)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Age: \(selectedAge)")
                    .font(.headline)
                HStack {
                    Text("18")
                        .font(.caption)
                    Slider(value: Binding(
                        get: { Double(selectedAge) },
                        set: { selectedAge = Int($0) }
                    ), in: 18...65, step: 1)
                    Text("65+")
                        .font(.caption)
                }
                
                Text(ageCategory.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var ageCategory: AgeCategory {
        switch selectedAge {
        case 18...24: return .youngAdult
        case 25...35: return .adult
        case 36...50: return .middleAged
        default: return .senior
        }
    }
    
    private var faceStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Customize your face")
                .font(.title2)
                .fontWeight(.bold)
            
            // Skin Tone
            CustomizationSection(title: "Skin Tone") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(SkinTone.allCases, id: \.self) { tone in
                            VStack {
                                Circle()
                                    .fill(tone.color)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(appearance.skinTone == tone ? Color.blue : Color.clear, lineWidth: 3)
                                    )
                                Text(tone.rawValue)
                                    .font(.caption2)
                            }
                            .onTapGesture {
                                appearance.skinTone = tone
                            }
                        }
                    }
                }
            }
            
            // Face Shape
            CustomizationSection(title: "Face Shape") {
                Picker("Face Shape", selection: $appearance.faceShape) {
                    ForEach(FaceShape.allCases, id: \.self) { shape in
                        Text(shape.rawValue).tag(shape)
                    }
                }
                .pickerStyle(.menu)
            }
            
            // Eye Color
            CustomizationSection(title: "Eye Color") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(EyeColor.allCases, id: \.self) { color in
                            VStack {
                                Circle()
                                    .fill(color.color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(appearance.eyeColor == color ? Color.blue : Color.clear, lineWidth: 3)
                                    )
                                Text(color.rawValue)
                                    .font(.caption2)
                            }
                            .onTapGesture {
                                appearance.eyeColor = color
                            }
                        }
                    }
                }
            }
            
            // Eye Shape
            CustomizationSection(title: "Eye Shape") {
                Picker("Eye Shape", selection: $appearance.eyeShape) {
                    ForEach(EyeShape.allCases, id: \.self) { shape in
                        Text(shape.rawValue).tag(shape)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
    
    private var hairStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Choose your hairstyle")
                .font(.title2)
                .fontWeight(.bold)
            
            // Hair Style
            CustomizationSection(title: "Hair Style") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                    ForEach(HairStyle.allCases, id: \.self) { style in
                        VStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(appearance.hairStyle == style ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                .frame(height: 60)
                                .overlay(
                                    Text(style.rawValue)
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(appearance.hairStyle == style ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        }
                        .onTapGesture {
                            appearance.hairStyle = style
                        }
                    }
                }
            }
            
            // Hair Color
            CustomizationSection(title: "Hair Color") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(HairColor.allCases, id: \.self) { color in
                            VStack {
                                Circle()
                                    .fill(color.color)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(appearance.hairColor == color ? Color.blue : Color.clear, lineWidth: 3)
                                    )
                                Text(color.rawValue)
                                    .font(.caption2)
                            }
                            .onTapGesture {
                                appearance.hairColor = color
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var bodyStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Complete your look")
                .font(.title2)
                .fontWeight(.bold)
            
            // Body Type
            CustomizationSection(title: "Body Type") {
                Picker("Body Type", selection: $appearance.bodyType) {
                    ForEach(BodyType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Height
            CustomizationSection(title: "Height") {
                Picker("Height", selection: $appearance.height) {
                    ForEach(Height.allCases, id: \.self) { height in
                        Text(height.rawValue).tag(height)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Actions
    private func createAvatar() {
        var newAvatar = Avatar(
            name: avatarName,
            gender: selectedGender,
            age: selectedAge,
            appearance: appearance
        )
        
        // Highest priority: Pre-made asset library model
        if usePreMadeAsset, let asset = selectedAsset {
            newAvatar.selectedAssetId = asset.id
            
            // Use asset's default values for appearance if not customized
            if appearance.skinTone == Appearance().skinTone {
                appearance.skinTone = asset.defaultSkinTone
            }
            if appearance.hairColor == Appearance().hairColor {
                appearance.hairColor = asset.defaultHairColor
            }
            if appearance.hairStyle == Appearance().hairStyle {
                appearance.hairStyle = asset.defaultHairStyle
            }
            newAvatar.appearance = appearance
        }
        // Second priority: ARKit TrueDepth scan data
        else if useTrueDepth, let geometry = capturedARGeometry {
            if #available(iOS 13.0, *) {
                // Serialize ARFaceGeometry
                if let serialized = TrueDepthFaceMeshBuilder.shared.serializeFaceGeometry(geometry) {
                    newAvatar.arFaceGeometryData = serialized
                }
            }
            if let arPhoto = capturedARPhoto {
                newAvatar.arFacePhotoData = arPhoto.jpegData(compressionQuality: 0.9)
            }
        }
        // Third priority: Vision framework scan
        else if useFaceScan, !useTrueDepth, let photo = capturedPhoto, let analysis = faceAnalysis {
            newAvatar.facePhotoData = photo.jpegData(compressionQuality: 0.8)
            // Note: FaceAnalysis encoding would require Codable conformance
            // For now, we'll regenerate from photo when rendering
        }
        // Final fallback: Procedural generation uses appearance properties set above
        
        viewModel.updateAvatar(newAvatar)
        dismiss()
    }
}

// MARK: - Supporting Views
struct CustomizationSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content
        }
    }
}

struct AvatarPreviewView: View {
    let appearance: Appearance
    let gender: Gender
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
            
            VStack(spacing: 16) {
                // Simple avatar representation
                ZStack {
                    // Head
                    Circle()
                        .fill(appearance.skinTone.color)
                        .frame(width: 100, height: 100)
                    
                    // Hair
                    if appearance.hairStyle != .bald {
                        Circle()
                            .fill(appearance.hairColor.color)
                            .frame(width: 100, height: 60)
                            .offset(y: -30)
                    }
                    
                    // Eyes
                    HStack(spacing: 20) {
                        Circle()
                            .fill(appearance.eyeColor.color)
                            .frame(width: 15, height: 15)
                        Circle()
                            .fill(appearance.eyeColor.color)
                            .frame(width: 15, height: 15)
                    }
                    .offset(y: -10)
                }
                
                // Body
                RoundedRectangle(cornerRadius: 10)
                    .fill(appearance.skinTone.color.opacity(0.8))
                    .frame(width: 80, height: 100)
            }
        }
    }
}

#Preview {
    AvatarCreatorView()
}
