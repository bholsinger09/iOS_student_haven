import AuthenticationServices
import Foundation
import Core
import SwiftUI

/// ViewModel for handling Apple Sign In
@MainActor
public final class AppleSignInViewModel: ObservableObject {
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    private let authRepository: AuthRepositoryProtocol
    
    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    /// Handle Apple Sign In authorization
    public func handleAppleSignIn(result: Result<ASAuthorization, Error>) async {
        isLoading = true
        errorMessage = nil
        
        switch result {
        case .success(let authorization):
            await processAppleAuthorization(authorization)
        case .failure(let error):
            handleAppleSignInError(error)
        }
        
        isLoading = false
    }
    
    private func processAppleAuthorization(_ authorization: ASAuthorization) async {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            errorMessage = "Invalid Apple ID credential"
            return
        }
        
        // Extract user information
        let userId = appleIDCredential.user
        let email = appleIDCredential.email ?? ""
        let fullName = formatFullName(appleIDCredential.fullName)
        
        // Get identity token
        guard let identityTokenData = appleIDCredential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8) else {
            errorMessage = "Failed to get identity token"
            return
        }
        
        do {
            // Here you would typically send the identityToken to your backend
            // For now, we'll create a mock session with the Apple ID data
            let user = User(
                id: userId,
                email: email.isEmpty ? "\(userId)@privaterelay.appleid.com" : email,
                name: fullName.isEmpty ? "Apple User" : fullName
            )
            
            // Notify AppState that user logged in via Apple
            NotificationCenter.default.post(
                name: Notification.Name.userDidLogin,
                object: user as Any
            )
            
        } catch {
            errorMessage = "Failed to authenticate with Apple ID"
        }
    }
    
    private func handleAppleSignInError(_ error: Error) {
        let authError = error as? ASAuthorizationError
        
        switch authError?.code {
        case .canceled:
            // User canceled the sign-in flow
            errorMessage = nil  // Don't show error for user cancellation
        case .failed:
            errorMessage = "Apple Sign In failed. Please try again."
        case .invalidResponse:
            errorMessage = "Invalid response from Apple"
        case .notHandled:
            errorMessage = "Sign in request was not handled"
        case .unknown:
            errorMessage = "An unknown error occurred"
        default:
            errorMessage = "Failed to sign in with Apple"
        }
    }
    
    private func formatFullName(_ nameComponents: PersonNameComponents?) -> String {
        guard let nameComponents = nameComponents else { return "" }
        
        let formatter = PersonNameComponentsFormatter()
        formatter.style = .default
        return formatter.string(from: nameComponents)
    }
}
