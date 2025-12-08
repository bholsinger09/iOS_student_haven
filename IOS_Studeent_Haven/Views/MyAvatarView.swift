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
    
    var body: some View {
        NavigationView {
            Group {
                if let avatar = viewModel.myAvatar {
                    avatarView(avatar)
                } else {
                    createAvatarPrompt
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("My Avatar")
            .sheet(isPresented: $showingCreator) {
                SimplifiedAvatarCreatorView(viewModel: viewModel)
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
                    if let assetId = avatar.selectedAssetId,
                       let asset = AvatarAsset.byId(assetId) {
                        Avatar3DPreviewViewLarge(asset: asset)
                            .frame(height: 450)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(20)
                            .shadow(radius: 2)
                    } else {
                        // Fallback if no asset selected
                        AvatarRenderer3D(avatar: avatar)
                            .frame(height: 450)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(20)
                            .shadow(radius: 2)
                    }
                    
                    Text(avatar.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let assetId = avatar.selectedAssetId,
                       let asset = AvatarAsset.byId(assetId) {
                        HStack(spacing: 20) {
                            VStack {
                                Text(asset.gender.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Gender")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                                .frame(height: 30)
                            
                            VStack {
                                Text(asset.bodyType.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Body Type")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                                .frame(height: 30)
                            
                            VStack {
                                Text(asset.ethnicity.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Ethnicity")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
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
                        
                        Text("Change Avatar")
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
            }
            .padding()
        }
    }
}



#Preview {
    MyAvatarView()
}
