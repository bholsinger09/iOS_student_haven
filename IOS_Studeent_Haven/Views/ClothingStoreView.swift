//
//  ClothingStoreView.swift
//  IOS_Student_Haven
//
//  Created on 12/7/24.
//

import SwiftUI
import StoreKit

struct ClothingStoreView: View {
    @StateObject private var viewModel = AvatarViewModel()
    @State private var selectedCategory: ClothingCategory?
    @State private var showingPurchaseAlert = false
    @State private var selectedCollection: ClothingCollection?
    
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Featured Collections
                    featuredCollectionsSection
                    
                    // Individual Items by Category
                    ForEach(ClothingCategory.allCases.filter { $0 != .fullOutfit }, id: \.self) { category in
                        categorySection(category)
                    }
                }
                .padding()
            }
            .navigationTitle("Clothing Store")
            .navigationBarTitleDisplayMode(.large)
            .alert("Purchase Complete", isPresented: $showingPurchaseAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your new items have been added to your wardrobe!")
            }
        }
    }
    
    // MARK: - Sections
    private var featuredCollectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                Text("Featured Collections")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(ClothingCollection.allCollections) { collection in
                        CollectionCard(
                            collection: collection,
                            isOwned: viewModel.isCollectionOwned(collection)
                        ) {
                            selectedCollection = collection
                            purchaseCollection(collection)
                        }
                    }
                }
            }
        }
    }
    
    private func categorySection(_ category: ClothingCategory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: categoryIcon(category))
                    .foregroundColor(.blue)
                Text(category.rawValue)
                    .font(.headline)
            }
            
            let items = premiumItemsByCategory[category] ?? []
            
            if items.isEmpty {
                Text("More items coming soon!")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(items) { item in
                        ClothingItemCard(
                            item: item,
                            isOwned: viewModel.myAvatar?.ownedClothingItems.contains(where: { $0.id == item.id }) ?? false
                        ) {
                            purchaseItem(item)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    private func purchaseCollection(_ collection: ClothingCollection) {
        // In a real app, this would trigger StoreKit purchase
        // For now, we'll simulate a purchase
        viewModel.purchaseCollection(collection)
        showingPurchaseAlert = true
    }
    
    private func purchaseItem(_ item: ClothingItem) {
        // In a real app, this would trigger StoreKit purchase
        viewModel.addClothingItem(item)
        showingPurchaseAlert = true
    }
    
    // MARK: - Helpers
    private func categoryIcon(_ category: ClothingCategory) -> String {
        switch category {
        case .top: return "tshirt"
        case .bottom: return "rectangle.portrait"
        case .shoes: return "shoe"
        case .outerwear: return "tshirt"
        case .accessories: return "eyeglasses"
        case .fullOutfit: return "sparkles"
        }
    }
    
    // Sample premium items (in a real app, these would come from your backend/StoreKit)
    private var premiumItemsByCategory: [ClothingCategory: [ClothingItem]] {
        [
            .top: [
                ClothingItem(name: "Graphic Tee", category: .top, isPremium: true, price: 0.99, color: .blue),
                ClothingItem(name: "Polo Shirt", category: .top, isPremium: true, price: 1.99, color: .green),
            ],
            .bottom: [
                ClothingItem(name: "Cargo Pants", category: .bottom, isPremium: true, price: 1.99, color: .neutral),
                ClothingItem(name: "Skirt", category: .bottom, isPremium: true, price: 1.99, color: .red),
            ],
            .shoes: [
                ClothingItem(name: "Boots", category: .shoes, isPremium: true, price: 2.99, color: .black),
                ClothingItem(name: "Sandals", category: .shoes, isPremium: true, price: 1.99, color: .neutral),
            ],
            .accessories: [
                ClothingItem(name: "Sunglasses", category: .accessories, isPremium: true, price: 0.99, color: .black),
                ClothingItem(name: "Watch", category: .accessories, isPremium: true, price: 1.99, color: .neutral),
            ]
        ]
    }
}

// MARK: - Supporting Views
struct CollectionCard: View {
    let collection: ClothingCollection
    let isOwned: Bool
    let onPurchase: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Collection preview
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(colors: [collectionColor.opacity(0.3), collectionColor.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 150)
                
                VStack {
                    Image(systemName: collectionIcon)
                        .font(.system(size: 50))
                        .foregroundColor(collectionColor)
                    Text("\(collection.items.count) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(collection.name)
                    .font(.headline)
                Text(collection.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            if isOwned {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Owned")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            } else {
                Button(action: onPurchase) {
                    HStack {
                        Text("$\(String(format: "%.2f", collection.price))")
                            .fontWeight(.bold)
                        Spacer()
                        Image(systemName: "cart.badge.plus")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .frame(width: 200)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
    
    private var collectionColor: Color {
        switch collection.name {
        case "Fall Collection": return .orange
        case "Professional": return .blue
        case "Athletic Wear": return .green
        case "College Pride": return .purple
        default: return .gray
        }
    }
    
    private var collectionIcon: String {
        switch collection.name {
        case "Fall Collection": return "leaf.fill"
        case "Professional": return "briefcase.fill"
        case "Athletic Wear": return "sportscourt.fill"
        case "College Pride": return "flag.fill"
        default: return "bag.fill"
        }
    }
}

struct ClothingItemCard: View {
    let item: ClothingItem
    let isOwned: Bool
    let onPurchase: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Item preview
            RoundedRectangle(cornerRadius: 12)
                .fill(item.color.color.opacity(0.3))
                .frame(height: 120)
                .overlay(
                    Image(systemName: categoryIcon)
                        .font(.system(size: 40))
                        .foregroundColor(item.color.color)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if let collectionName = item.collectionName {
                    Text(collectionName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if isOwned {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Owned")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
            } else if let price = item.price {
                Button(action: onPurchase) {
                    Text("$\(String(format: "%.2f", price))")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var categoryIcon: String {
        switch item.category {
        case .top: return "tshirt.fill"
        case .bottom: return "rectangle.portrait.fill"
        case .shoes: return "shoe.fill"
        case .outerwear: return "cloud.fill"
        case .accessories: return "eyeglasses"
        case .fullOutfit: return "sparkles"
        }
    }
}

#Preview {
    ClothingStoreView()
}
