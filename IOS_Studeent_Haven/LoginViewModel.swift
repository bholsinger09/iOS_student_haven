import Combine
import Core
import Foundation

/// ViewModel for Login screen
@MainActor
public final class LoginViewModel: ObservableObject {
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var isLoggedIn: Bool = false

    private let loginUseCase: LoginUseCase
    public let authRepository: AuthRepositoryProtocol

    public init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
        self.authRepository = loginUseCase.authRepository
    }

    public func login() async {
        isLoading = true
        errorMessage = nil

        do {
            let credentials = LoginCredentials(email: email, password: password)
            let session = try await loginUseCase.execute(credentials: credentials)
            isLoggedIn = true

            // Notify AppState that user logged in
            NotificationCenter.default.post(
                name: .userDidLogin,
                object: session.user
            )
        } catch let error as AppError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "An unexpected error occurred"
        }

        isLoading = false
    }

    public func clearError() {
        errorMessage = nil
    }
}
