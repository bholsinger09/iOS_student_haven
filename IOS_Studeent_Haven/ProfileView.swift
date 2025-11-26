import Authentication
import Core
import SwiftUI

/// Profile view showing user information and account settings
struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: ProfileViewModel
    @State private var showingImagePicker = false
    @State private var showingEditSheet = false
    @State private var showingChangePasswordSheet = false

    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        profileHeader

                        // Account Statistics
                        statisticsSection

                        // Account Actions
                        actionsSection

                        // Danger Zone
                        dangerZoneSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        showingEditSheet = true
                    }
                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                EditProfileView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingChangePasswordSheet) {
                ChangePasswordView(viewModel: viewModel)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile Photo
            ZStack {
                if let photoURL = viewModel.profilePhotoURL {
                    AsyncImage(url: photoURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color(red: 0.73, green: 0.33, blue: 0.83))
                        .frame(width: 100, height: 100)
                        .overlay {
                            Text(viewModel.userInitials)
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                }

                // Camera button overlay
                Button {
                    showingImagePicker = true
                } label: {
                    Circle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 32, height: 32)
                        .overlay {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                        }
                }
                .offset(x: 35, y: 35)
            }

            // User Info
            VStack(spacing: 8) {
                Text(viewModel.userName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(viewModel.userEmail)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if let college = viewModel.userCollege {
                    HStack(spacing: 4) {
                        Image(systemName: "building.columns.fill")
                            .font(.caption)
                        Text(college)
                            .font(.caption)
                    }
                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.73, green: 0.33, blue: 0.83).opacity(0.2))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.vertical, 24)
    }

    // MARK: - Statistics Section

    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Statistics")
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 16) {
                ProfileStatCard(
                    icon: "book.fill",
                    title: "Classes",
                    value: "\(viewModel.classCount)",
                    color: .blue
                )

                ProfileStatCard(
                    icon: "note.text",
                    title: "Notes",
                    value: "\(viewModel.noteCount)",
                    color: .green
                )

                ProfileStatCard(
                    icon: "rectangle.stack.fill",
                    title: "Flashcards",
                    value: "\(viewModel.flashcardCount)",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account")
                .font(.headline)
                .foregroundColor(.white)

            VStack(spacing: 0) {
                ActionRow(
                    icon: "person.fill",
                    title: "Edit Profile",
                    color: Color(red: 0.73, green: 0.33, blue: 0.83)
                ) {
                    showingEditSheet = true
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                ActionRow(
                    icon: "lock.fill",
                    title: "Change Password",
                    color: .blue
                ) {
                    showingChangePasswordSheet = true
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                NavigationLink {
                    SettingsView()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "gear")
                            .foregroundColor(.gray)
                            .frame(width: 24)

                        Text("Settings")
                            .foregroundColor(.white)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    .padding()
                }
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }

    // MARK: - Danger Zone

    private var dangerZoneSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Danger Zone")
                .font(.headline)
                .foregroundColor(.red)

            Button {
                Task {
                    await viewModel.logout()
                }
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Log Out")
                        .fontWeight(.semibold)
                    Spacer()
                }
                .foregroundColor(.red)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Profile Stat Card Component

struct ProfileStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Action Row Component

struct ActionRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)

                Text(title)
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding()
        }
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    @State private var name: String = ""
    @State private var email: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .foregroundColor(.gray)
                        TextField("Enter your name", text: $name)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .foregroundColor(.gray)
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.updateProfile(name: name, email: email)
                            dismiss()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .onAppear {
                name = viewModel.userName
                email = viewModel.userEmail
            }
        }
    }
}

// MARK: - Change Password View

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Password")
                            .foregroundColor(.gray)
                        SecureField("Enter current password", text: $currentPassword)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("New Password")
                            .foregroundColor(.gray)
                        SecureField("Enter new password", text: $newPassword)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .foregroundColor(.gray)
                        SecureField("Confirm new password", text: $confirmPassword)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)

                    Text("Password must be at least 6 characters")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)

                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationTitle("Change Password")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            if newPassword == confirmPassword {
                                await viewModel.changePassword(
                                    current: currentPassword,
                                    new: newPassword
                                )
                                dismiss()
                            }
                        }
                    }
                    .disabled(
                        viewModel.isLoading || newPassword.count < 6
                            || newPassword != confirmPassword)
                }
            }
        }
    }
}
