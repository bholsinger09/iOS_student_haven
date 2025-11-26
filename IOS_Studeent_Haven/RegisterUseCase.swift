import Core
import Foundation

/// Use case for user registration
public final class RegisterUseCase {
    private let authRepository: AuthRepositoryProtocol

    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    public func execute(data: RegistrationData) async throws -> AuthSession {
        // Validate registration data
        guard !data.email.isEmpty else {
            throw AppError.invalidData("Email cannot be empty")
        }

        guard !data.password.isEmpty else {
            throw AppError.invalidData("Password cannot be empty")
        }

        guard !data.name.isEmpty else {
            throw AppError.invalidData("Name cannot be empty")
        }

        guard isValidEmail(data.email) else {
            throw AppError.invalidData("Invalid email format")
        }

        guard isValidPassword(data.password) else {
            throw AppError.invalidData("Password must be at least 8 characters long")
        }

        // Attempt registration
        return try await authRepository.register(data: data)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func isValidPassword(_ password: String) -> Bool {
        return password.count >= 8
    }
}
