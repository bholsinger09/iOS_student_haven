//
//  PartnerPreferencesView.swift
//  IOS_Student_Haven
//
//  Created on 12/7/24.
//

import SwiftUI

struct PartnerPreferencesView: View {
    @StateObject private var viewModel = AvatarViewModel()
    @State private var preferences: StudyPartnerPreferences
    @State private var showingSaveAlert = false
    
    init() {
        _preferences = State(initialValue: StudyPartnerPreferences())
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Enable Partner Matching", isOn: $preferences.matchingEnabled)
                        .tint(.blue)
                } header: {
                    Text("Matching")
                } footer: {
                    Text("When enabled, you'll be matched with study partners based on your preferences")
                }
                
                if preferences.matchingEnabled {
                    Section("Gender Preference") {
                        Picker("Preferred Gender", selection: $preferences.preferredGender) {
                            Text("No Preference").tag(nil as Gender?)
                            ForEach(Gender.allCases, id: \.self) { gender in
                                Text(gender.rawValue).tag(gender as Gender?)
                            }
                        }
                    }
                    
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Age Range: \(Int(preferences.ageRange.lowerBound)) - \(Int(preferences.ageRange.upperBound))")
                                .font(.subheadline)
                            
                            HStack {
                                Text("18")
                                    .font(.caption)
                                Slider(
                                    value: Binding(
                                        get: { Double(preferences.ageRange.lowerBound) },
                                        set: { newValue in
                                            let lower = Int(newValue)
                                            let upper = max(lower, preferences.ageRange.upperBound)
                                            preferences.ageRange = lower...upper
                                        }
                                    ),
                                    in: 18...65
                                )
                                Text("65")
                                    .font(.caption)
                            }
                            
                            HStack {
                                Text("18")
                                    .font(.caption)
                                Slider(
                                    value: Binding(
                                        get: { Double(preferences.ageRange.upperBound) },
                                        set: { newValue in
                                            let upper = Int(newValue)
                                            let lower = min(upper, preferences.ageRange.lowerBound)
                                            preferences.ageRange = lower...upper
                                        }
                                    ),
                                    in: 18...65
                                )
                                Text("65")
                                    .font(.caption)
                            }
                        }
                    } header: {
                        Text("Age Range")
                    } footer: {
                        Text("Select the age range for potential study partners")
                    }
                    
                    Section("Appearance Preferences") {
                        NavigationLink(destination: HairStylePreferencesView(selectedStyles: $preferences.preferredAppearance.hairStyles)) {
                            HStack {
                                Text("Hair Styles")
                                Spacer()
                                Text("\(preferences.preferredAppearance.hairStyles.count) selected")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        NavigationLink(destination: BodyTypePreferencesView(selectedTypes: $preferences.preferredAppearance.bodyTypes)) {
                            HStack {
                                Text("Body Types")
                                Spacer()
                                Text("\(preferences.preferredAppearance.bodyTypes.count) selected")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        NavigationLink(destination: HeightPreferencesView(selectedHeights: $preferences.preferredAppearance.heights)) {
                            HStack {
                                Text("Heights")
                                Spacer()
                                Text("\(preferences.preferredAppearance.heights.count) selected")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Section {
                        Text("Leave preferences empty to match with anyone")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Partner Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePreferences()
                    }
                }
            }
            .alert("Preferences Saved", isPresented: $showingSaveAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your study partner preferences have been updated")
            }
            .onAppear {
                if let savedPreferences = viewModel.idealPartnerPreferences {
                    preferences = savedPreferences
                }
            }
        }
    }
    
    private func savePreferences() {
        viewModel.updatePartnerPreferences(preferences)
        showingSaveAlert = true
    }
}

// MARK: - Supporting Views
struct HairStylePreferencesView: View {
    @Binding var selectedStyles: [HairStyle]
    
    var body: some View {
        List(HairStyle.allCases, id: \.self) { style in
            Button(action: {
                toggleSelection(style)
            }) {
                HStack {
                    Text(style.rawValue)
                    Spacer()
                    if selectedStyles.contains(style) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle("Hair Style Preferences")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func toggleSelection(_ style: HairStyle) {
        if let index = selectedStyles.firstIndex(of: style) {
            selectedStyles.remove(at: index)
        } else {
            selectedStyles.append(style)
        }
    }
}

struct BodyTypePreferencesView: View {
    @Binding var selectedTypes: [BodyType]
    
    var body: some View {
        List(BodyType.allCases, id: \.self) { type in
            Button(action: {
                toggleSelection(type)
            }) {
                HStack {
                    Text(type.rawValue)
                    Spacer()
                    if selectedTypes.contains(type) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle("Body Type Preferences")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func toggleSelection(_ type: BodyType) {
        if let index = selectedTypes.firstIndex(of: type) {
            selectedTypes.remove(at: index)
        } else {
            selectedTypes.append(type)
        }
    }
}

struct HeightPreferencesView: View {
    @Binding var selectedHeights: [Height]
    
    var body: some View {
        List(Height.allCases, id: \.self) { height in
            Button(action: {
                toggleSelection(height)
            }) {
                HStack {
                    Text(height.rawValue)
                    Spacer()
                    if selectedHeights.contains(height) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle("Height Preferences")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func toggleSelection(_ height: Height) {
        if let index = selectedHeights.firstIndex(of: height) {
            selectedHeights.remove(at: index)
        } else {
            selectedHeights.append(height)
        }
    }
}

#Preview {
    PartnerPreferencesView()
}
