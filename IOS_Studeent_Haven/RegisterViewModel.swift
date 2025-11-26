import Combine
import Core
import Foundation

/// ViewModel for Registration screen
@MainActor
public final class RegisterViewModel: ObservableObject {
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var confirmPassword: String = ""
    @Published public var name: String = ""
    @Published public var selectedCollegeId: UUID?
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var isRegistered: Bool = false

    private let registerUseCase: RegisterUseCase

    public init(registerUseCase: RegisterUseCase) {
        self.registerUseCase = registerUseCase
    }

    public func register() async {
        isLoading = true
        errorMessage = nil

        // Validate passwords match
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            isLoading = false
            return
        }

        do {
            let data = RegistrationData(
                email: email,
                password: password,
                name: name,
                collegeId: selectedCollegeId?.uuidString
            )
            _ = try await registerUseCase.execute(data: data)
            isRegistered = true
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
