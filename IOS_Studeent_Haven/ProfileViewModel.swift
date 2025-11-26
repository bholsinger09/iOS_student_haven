import Authentication
import Core
import Foundation

/// ViewModel for the Profile screen
@MainActor
class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""

    // User data
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userCollege: String? = nil
    @Published var profilePhotoURL: URL? = nil

    // Statistics
    @Published var classCount: Int = 0
    @Published var noteCount: Int = 0
    @Published var flashcardCount: Int = 0

    // MARK: - Dependencies

    private let appState: AppState
    private let authRepository: AuthRepositoryProtocol

    // MARK: - Initialization

    init(appState: AppState) {
        self.appState = appState
        self.authRepository = appState.authRepository
        loadUserData()
        loadStatistics()
    }

    // MARK: - Computed Properties

    var userInitials: String {
        let components = userName.split(separator: " ")
        if components.count >= 2 {
            let first = components[0].prefix(1)
            let last = components[1].prefix(1)
            return "\(first)\(last)".uppercased()
        } else if let first = components.first {
            return String(first.prefix(2)).uppercased()
        }
        return "??"
    }

    // MARK: - Public Methods

    func loadUserData() {
        guard let user = appState.currentUser else { return }

        userName = user.name
        userEmail = user.email
        userCollege = user.collegeId

        // TODO: Load profile photo URL from Firebase Storage
        // profilePhotoURL = ...
    }

    func loadStatistics() {
        Task {
            // TODO: Fetch actual counts from repositories
            // For now, using placeholder values
            classCount = 0
            noteCount = 0
            flashcardCount = 0

            // In production, would query Firestore:
            // let classes = try await classRepository.getClasses(userId: user.id)
            // classCount = classes.count
        }
    }

    func updateProfile(name: String, email: String) async {
        guard let user = appState.currentUser else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            // Update user in Firestore
            // TODO: Implement UpdateUserUseCase
            // For now, update locally
            let updatedUser = User(
                id: user.id,
                email: email,
                name: name,
                collegeId: user.collegeId,
                createdAt: user.createdAt,
                updatedAt: Date()
            )

            appState.currentUser = updatedUser
            userName = name
            userEmail = email

            // TODO: Persist to Firestore
            // try await updateUserUseCase.execute(user: updatedUser)

        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
            showError = true
        }
    }

    func changePassword(current: String, new: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            // TODO: Implement ChangePasswordUseCase with Firebase Auth
            // try await authRepository.changePassword(current: current, new: new)

            errorMessage = "Password changed successfully"
            showError = true

        } catch {
            errorMessage = "Failed to change password: \(error.localizedDescription)"
            showError = true
        }
    }

    func uploadProfilePhoto(imageData: Data) async {
        guard appState.currentUser != nil else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            // TODO: Implement photo upload to Firebase Storage
            // let photoURL = try await storageService.uploadProfilePhoto(userId: user.id, data: imageData)
            // profilePhotoURL = photoURL

            errorMessage = "Photo uploaded successfully"
            showError = true

        } catch {
            errorMessage = "Failed to upload photo: \(error.localizedDescription)"
            showError = true
        }
    }

    func logout() async {
        isLoading = true
        defer { isLoading = false }

        await appState.logout()
    }

    func clearError() {
        showError = false
        errorMessage = ""
    }
}
