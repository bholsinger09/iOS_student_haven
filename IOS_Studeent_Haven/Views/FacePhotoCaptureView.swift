//
//  FacePhotoCaptureView.swift
//  IOS_Student_Haven
//
//  Camera view for capturing face photo for Vision framework analysis
//

import SwiftUI
import UIKit
import AVFoundation

struct FacePhotoCaptureView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var capturedImage: UIImage?
    @Binding var faceAnalysis: FaceAnalysis?
    
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var isAnalyzing = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Scan Your Face")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("We'll use Apple Vision to create a realistic 3D avatar from your face")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if isAnalyzing {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Analyzing face...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 300)
                } else if let image = capturedImage {
                    // Show captured photo with face analysis overlay
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .cornerRadius(12)
                        
                        if let analysis = faceAnalysis {
                            // Show success indicator
                            VStack {
                                Spacer()
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Face detected!")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(8)
                                .padding()
                            }
                        }
                    }
                    .padding()
                    
                    if errorMessage != nil {
                        Text(errorMessage!)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    
                    Button(action: {
                        if faceAnalysis != nil {
                            dismiss()
                        }
                    }) {
                        Text("Use This Photo")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(faceAnalysis != nil ? Color.blue : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(faceAnalysis == nil)
                    .padding(.horizontal)
                    
                    Button(action: {
                        capturedImage = nil
                        faceAnalysis = nil
                        errorMessage = nil
                    }) {
                        Text("Retake Photo")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                } else {
                    VStack(spacing: 16) {
                        // Instructions
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "1.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Look directly at the camera")
                                    .font(.subheadline)
                            }
                            
                            HStack {
                                Image(systemName: "2.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Ensure good lighting")
                                    .font(.subheadline)
                            }
                            
                            HStack {
                                Image(systemName: "3.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Keep a neutral expression")
                                    .font(.subheadline)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Camera option
                        Button(action: {
                            sourceType = .camera
                            showImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                Text("Take Photo")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // Photo library option
                        Button(action: {
                            sourceType = .photoLibrary
                            showImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "photo.fill")
                                    .font(.title2)
                                Text("Choose from Library")
                                    .font(.headline)
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Face Scan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                FaceImagePicker(sourceType: sourceType, selectedImage: $capturedImage)
            }
            .onChange(of: capturedImage) { _, newImage in
                if let image = newImage {
                    analyzeFace(image: image)
                }
            }
        }
    }
    
    private func analyzeFace(image: UIImage) {
        isAnalyzing = true
        errorMessage = nil
        
        VisionFaceCaptureService.shared.detectFace(in: image) { result in
            DispatchQueue.main.async {
                isAnalyzing = false
                
                switch result {
                case .success(let analysis):
                    faceAnalysis = analysis
                    errorMessage = nil
                case .failure(let error):
                    faceAnalysis = nil
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Face Image Picker

struct FaceImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: FaceImagePicker
        
        init(_ parent: FaceImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                parent.selectedImage = image
            } else if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
