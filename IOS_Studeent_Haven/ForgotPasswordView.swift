import Authentication
import Core
import SwiftUI

/// View for resetting forgotten password
public struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ForgotPasswordViewModel

    public init(authRepository: AuthRepositoryProtocol) {
        _viewModel = StateObject(
            wrappedValue: ForgotPasswordViewModel(authRepository: authRepository))
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "lock.rotation")
                            .font(.system(size: 60))
                            .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))

                        Text("Reset Password")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text(
                            "Enter your email address and we'll send you instructions to reset your password"
                        )
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    }
                    .padding(.top, 40)

                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        TextField("Enter your email", text: $viewModel.email)
                            .textFieldStyle(.roundedBorder)
                            .disabled(viewModel.isLoading)
                    }
                    .padding(.horizontal)

                    // Send Button
                    Button {
                        Task {
                            await viewModel.sendResetEmail()
                        }
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            } else {
                                Text("Send Reset Link")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.73, green: 0.33, blue: 0.83))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isLoading || viewModel.email.isEmpty)
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .navigationTitle("Forgot Password")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Success", isPresented: $viewModel.showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Password reset instructions have been sent to \(viewModel.email)")
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

// MARK: - View Model

@MainActor
class ForgotPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var showSuccess = false
    @Published var errorMessage = ""

    private let resetPasswordUseCase: ResetPasswordUseCase

    init(authRepository: AuthRepositoryProtocol) {
        self.resetPasswordUseCase = ResetPasswordUseCase(authRepository: authRepository)
    }

    func sendResetEmail() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await resetPasswordUseCase.execute(email: email)
            showSuccess = true
        } catch let error as AppError {
            errorMessage = error.localizedDescription
            showError = true
        } catch {
            errorMessage = "Failed to send reset email. Please try again."
            showError = true
        }
    }

    func clearError() {
        showError = false
        errorMessage = ""
    }
}
