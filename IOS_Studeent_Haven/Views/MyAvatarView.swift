//
//  MyAvatarView.swift
//  IOS_Student_Haven
//
//  Created on 12/7/24.
//

import SwiftUI

struct MyAvatarView: View {
    @StateObject private var viewModel = AvatarViewModel()
    @State private var showingCreator = false
    @State private var showingWardrobe = false
    @State private var selectedOutfitItem: ClothingCategory?
    
    var body: some View {
        NavigationView {
            Group {
                if let avatar = viewModel.myAvatar {
                    avatarView(avatar)
                } else {
                    createAvatarPrompt
                }
            }
            .navigationTitle("My Avatar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ClothingStoreView()) {
                        Image(systemName: "cart")
                    }
                }
            }
            .sheet(isPresented: $showingCreator) {
                AvatarCreatorView()
            }
            .sheet(isPresented: $showingWardrobe) {
                WardrobeView(viewModel: viewModel, selectedCategory: $selectedOutfitItem)
            }
        }
    }
    
    // MARK: - Views
    private var createAvatarPrompt: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.circle")
                .font(.system(size: 100))
                .foregroundColor(.gray)
            
            Text("Create Your Avatar")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Design a custom character to represent you in the Student Haven community")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: {
                showingCreator = true
            }) {
                Text("Get Started")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private func avatarView(_ avatar: Avatar) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Avatar display card
                VStack(spacing: 16) {
                    // Show 3D avatar
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        AvatarRenderer3D(avatar: avatar)
                            .frame(height: 450)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    
                    Text(avatar.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text(avatar.gender.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Gender")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                            .frame(height: 30)
                        
                        VStack {
                            Text(avatar.appearance.height.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Height")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                            .frame(height: 30)
                        
                        VStack {
                            Text(avatar.appearance.bodyType.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Build")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(radius: 4)
                
                // Edit avatar button
                Button(action: {
                    showingCreator = true
                }) {
                    HStack {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title3)
                        
                        Text("Edit Avatar")
                            .font(.headline)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Current outfit section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Current Outfit")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        OutfitItemRow(
                            title: "Top",
                            item: avatar.currentOutfit.top,
                            icon: "tshirt"
                        ) {
                            selectedOutfitItem = .top
                            showingWardrobe = true
                        }
                        
                        OutfitItemRow(
                            title: "Bottom",
                            item: avatar.currentOutfit.bottom,
                            icon: "rectangle.portrait"
                        ) {
                            selectedOutfitItem = .bottom
                            showingWardrobe = true
                        }
                        
                        OutfitItemRow(
                            title: "Shoes",
                            item: avatar.currentOutfit.shoes,
                            icon: "shoe"
                        ) {
                            selectedOutfitItem = .shoes
                            showingWardrobe = true
                        }
                        
                        OutfitItemRow(
                            title: "Outerwear",
                            item: avatar.currentOutfit.outerwear,
                            icon: "cloud"
                        ) {
                            selectedOutfitItem = .outerwear
                            showingWardrobe = true
                        }
                    }
                }
                .padding()
                
                // Quick actions
                VStack(spacing: 12) {
                    Button(action: {
                        showingCreator = true
                    }) {
                        Label("Edit Appearance", systemImage: "slider.horizontal.3")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                    }
                    
                    NavigationLink(destination: ClothingStoreView()) {
                        Label("Visit Store", systemImage: "cart")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

// MARK: - Supporting Views
struct OutfitItemRow: View {
    let title: String
    let item: ClothingItem?
    let icon: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(item?.name ?? "Not wearing")
                        .font(.callout)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

struct WardrobeView: View {
    @ObservedObject var viewModel: AvatarViewModel
    @Binding var selectedCategory: ClothingCategory?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Group {
                if let category = selectedCategory {
                    let items = viewModel.getFilteredClothing(category: category)
                    
                    if items.isEmpty {
                        emptyWardrobeView
                    } else {
                        itemsListView(items: items)
                    }
                } else {
                    Text("Select a category")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Wardrobe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var emptyWardrobeView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tshirt")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No items in this category")
                .font(.headline)
            
            Text("Visit the store to purchase new clothing")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            NavigationLink(destination: ClothingStoreView()) {
                Text("Browse Store")
                    .fontWeight(.semibold)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
    
    private func itemsListView(items: [ClothingItem]) -> some View {
        List(items) { item in
            Button(action: {
                wearItem(item)
                dismiss()
            }) {
                HStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(item.color.color.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "tshirt")
                                .foregroundColor(item.color.color)
                        )
                    
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.headline)
                        if let collection = item.collectionName {
                            Text(collection)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if isCurrentlyWearing(item) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
    
    private func wearItem(_ item: ClothingItem) {
        guard var avatar = viewModel.myAvatar else { return }
        var outfit = avatar.currentOutfit
        
        switch item.category {
        case .top:
            outfit.top = item
        case .bottom:
            outfit.bottom = item
        case .shoes:
            outfit.shoes = item
        case .outerwear:
            outfit.outerwear = item
        case .accessories:
            if !outfit.accessories.contains(where: { $0.id == item.id }) {
                outfit.accessories.append(item)
            }
        case .fullOutfit:
            break
        }
        
        viewModel.updateOutfit(outfit)
    }
    
    private func isCurrentlyWearing(_ item: ClothingItem) -> Bool {
        guard let outfit = viewModel.myAvatar?.currentOutfit else { return false }
        
        switch item.category {
        case .top: return outfit.top?.id == item.id
        case .bottom: return outfit.bottom?.id == item.id
        case .shoes: return outfit.shoes?.id == item.id
        case .outerwear: return outfit.outerwear?.id == item.id
        case .accessories: return outfit.accessories.contains(where: { $0.id == item.id })
        case .fullOutfit: return false
        }
    }
}

#Preview {
    MyAvatarView()
}
