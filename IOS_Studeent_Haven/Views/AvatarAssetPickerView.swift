//
//  AvatarAssetPickerView.swift
//  IOS_Student_Haven
//
//  Allows users to browse and select pre-made 3D avatar assets
//

import SwiftUI

struct AvatarAssetPickerView: View {
    @Binding var selectedAsset: AvatarAsset?
    @Environment(\.dismiss) private var dismiss
    
    let filterGender: Gender
    
    @State private var selectedCategory: AssetCategory = .all
    @State private var searchText = ""
    
    enum AssetCategory: String, CaseIterable {
        case all = "All"
        case matching = "Matching Gender"
        case slim = "Slim"
        case average = "Average"
        case athletic = "Athletic"
    }
    
    var filteredAssets: [AvatarAsset] {
        var assets = AvatarAsset.library
        
        // Apply category filter
        switch selectedCategory {
        case .all:
            break
        case .matching:
            assets = assets.filter { $0.gender == filterGender }
        case .slim:
            assets = assets.filter { $0.bodyType == .slim }
        case .average:
            assets = assets.filter { $0.bodyType == .average }
        case .athletic:
            assets = assets.filter { $0.bodyType == .athletic }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            assets = assets.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.ethnicity.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return assets
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search avatars...", text: $searchText)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)
                
                // Category picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(AssetCategory.allCases, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedCategory == category ? Color.blue : Color(.systemGray5)
                                    )
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)
                
                // Avatar grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(filteredAssets) { asset in
                            AvatarAssetCard(
                                asset: asset,
                                isSelected: selectedAsset?.id == asset.id
                            ) {
                                selectedAsset = asset
                                dismiss()
                            }
                        }
                    }
                    .padding()
                }
                
                if filteredAssets.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No avatars found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Try adjusting your filters or search")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                }
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

struct AvatarAssetCard: View {
    let asset: AvatarAsset
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                // Thumbnail image (placeholder for now)
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    asset.defaultSkinTone.color.opacity(0.3),
                                    asset.defaultHairColor.color.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Placeholder icon
                    VStack(spacing: 4) {
                        Image(systemName: genderIcon)
                            .font(.system(size: 40))
                            .foregroundColor(asset.defaultSkinTone.color)
                        
                        Text(asset.name)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                    .padding(8)
                            }
                            Spacer()
                        }
                    }
                }
                .aspectRatio(0.75, contentMode: .fit)
                
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
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.green : Color.gray.opacity(0.2), lineWidth: isSelected ? 3 : 1)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isSelected ? Color.green.opacity(0.05) : Color(.systemBackground))
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var genderIcon: String {
        switch asset.gender {
        case .male: return "person.fill"
        case .female: return "person.fill"
        case .other: return "person.fill.questionmark"
        }
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

#Preview {
    AvatarAssetPickerView(
        selectedAsset: .constant(nil),
        filterGender: .other
    )
}
