import Core
import Foundation

/// Use case for user login
public final class LoginUseCase {
    public let authRepository: AuthRepositoryProtocol

    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    public func execute(credentials: LoginCredentials) async throws -> AuthSession {
        // Validate credentials
        guard !credentials.email.isEmpty else {
            throw AppError.invalidData("Email cannot be empty")
        }

        guard !credentials.password.isEmpty else {
            throw AppError.invalidData("Password cannot be empty")
        }

        guard isValidEmail(credentials.email) else {
            throw AppError.invalidData("Invalid email format")
        }

        // Attempt login
        return try await authRepository.login(credentials: credentials)
    }

    private func isValidEmail(_ email: String) -> Bool {
        // Simple validation: contains @ and a dot after @
        guard email.contains("@") else { return false }
        let components = email.components(separatedBy: "@")
        guard components.count == 2, !components[0].isEmpty, !components[1].isEmpty else {
            return false
        }
        return components[1].contains(".")
    }
}
