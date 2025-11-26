import SwiftUI
import Core

/// Settings view with account management options
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAccountAlert = false
    @State private var confirmationEmail = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // App Info Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 0) {
                            SettingRow(
                                icon: "info.circle",
                                title: "Version",
                                value: "1.0.0",
                                color: .blue
                            )
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                            
                            Link(destination: URL(string: "https://bholsinger09.github.io/StudentStudyHaven/support.html")!) {
                                HStack(spacing: 12) {
                                    Image(systemName: "questionmark.circle")
                                        .foregroundColor(.green)
                                        .frame(width: 24)
                                    
                                    Text("Support & Help")
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.right")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                .padding()
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                            
                            Link(destination: URL(string: "https://bholsinger09.github.io/StudentStudyHaven/support.html")!) {
                                HStack(spacing: 12) {
                                    Image(systemName: "lock.shield")
                                        .foregroundColor(.orange)
                                        .frame(width: 24)
                                    
                                    Text("Privacy Policy")
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.right")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                .padding()
                            }
                        }
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Account Management Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Account")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 12) {
                            Button {
                                showDeleteAccountAlert = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.white)
                                        .frame(width: 24)
                                    
                                    Text("Delete Account")
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.red)
                                .cornerRadius(12)
                            }
                            
                            // Help link for account deletion
                            Link(destination: URL(string: "https://bholsinger09.github.io/StudentStudyHaven/support.html#delete-account")!) {
                                HStack {
                                    Image(systemName: "questionmark.circle.fill")
                                    Text("Need help deleting your account?")
                                        .font(.caption)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption2)
                                }
                                .foregroundColor(.gray)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
            TextField("Enter your email to confirm", text: $confirmationEmail)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
            Button("Cancel", role: .cancel) {
                confirmationEmail = ""
            }
            Button("Delete Account", role: .destructive) {
                Task {
                    await deleteAccount()
                }
            }
        } message: {
            Text("⚠️ This action is permanent and cannot be undone.\n\nAll your classes, notes, flashcards, and study data will be permanently deleted.\n\nEnter your email to confirm: \(appState.currentUser?.email ?? "")")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {
                errorMessage = ""
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func deleteAccount() async {
        guard let user = appState.currentUser else { return }
        
        // Verify email matches
        guard confirmationEmail.lowercased() == user.email.lowercased() else {
            errorMessage = "Email does not match. Account deletion cancelled."
            showError = true
            confirmationEmail = ""
            return
        }
        
        do {
            // Delete the account
            try await appState.authRepository.deleteAccount()
            
            // Log out and return to login screen
            await appState.logout()
            confirmationEmail = ""
            
        } catch {
            errorMessage = "Failed to delete account: \(error.localizedDescription)\n\nPlease contact support@studentstudyhaven.com for assistance."
            showError = true
            confirmationEmail = ""
        }
    }
}

// MARK: - Setting Row Component
struct SettingRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.gray)
                .font(.subheadline)
        }
        .padding()
    }
}
