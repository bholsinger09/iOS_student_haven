import Core
import Foundation

/// Use case for password reset
public final class ResetPasswordUseCase {
    private let authRepository: any AuthRepositoryProtocol

    public init(authRepository: any AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    public func execute(email: String) async throws {
        // Validate email
        guard !email.isEmpty else {
            throw AppError.invalidData("Email cannot be empty")
        }

        guard isValidEmail(email) else {
            throw AppError.invalidData("Invalid email format")
        }

        // TODO: Implement password reset with Firebase Auth
        // For now, simulate success
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // In production, would call:
        // try await authRepository.resetPassword(email: email)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
