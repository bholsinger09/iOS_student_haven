import Core
import SwiftUI

/// Login screen view
public struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @State private var isPasswordVisible = false

    public init(viewModel: LoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                // Black background
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 25) {
                    Spacer()

                    // App Logo/Title with softer styling
                    VStack(spacing: 12) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 70))
                            .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                        Text("StudentStudyHaven")
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                    }
                    .padding(.top, 40)

                    Spacer()

                    // Login Form with card styling
                    VStack(spacing: 20) {
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                            TextField("Enter your email", text: $viewModel.email)
                                .textFieldStyle(.plain)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            Color(red: 0.73, green: 0.33, blue: 0.83).opacity(0.3),
                                            lineWidth: 1)
                                )
                        }

                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                            HStack {
                                if isPasswordVisible {
                                    TextField("Enter your password", text: $viewModel.password)
                                        .textFieldStyle(.plain)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                        .textContentType(.password)
                                } else {
                                    SecureField("Enter your password", text: $viewModel.password)
                                        .textFieldStyle(.plain)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                        .textContentType(.password)
                                }
                                Button(action: {
                                    isPasswordVisible.toggle()
                                }) {
                                    Image(
                                        systemName: isPasswordVisible
                                            ? "eye.slash.fill" : "eye.fill"
                                    )
                                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        Color(red: 0.73, green: 0.33, blue: 0.83).opacity(0.3),
                                        lineWidth: 1)
                            )
                        }

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red.opacity(0.8))
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                        }

                        // Forgot Password Link
                        HStack {
                            Spacer()
                            NavigationLink("Forgot Password?") {
                                ForgotPasswordView(authRepository: viewModel.authRepository)
                            }
                            .font(.caption)
                            .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                        }

                        // Login button with dark blue background
                        Button(action: {
                            Task {
                                await viewModel.login()
                            }
                        }) {
                            HStack {
                                Spacer()
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(Color(red: 0.9, green: 0.4, blue: 0.5))
                                } else {
                                    Text("Login")
                                        .fontWeight(.semibold)
                                        .font(.headline)
                                        .foregroundColor(Color(red: 0.9, green: 0.4, blue: 0.5))
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color(red: 0.0, green: 0.2, blue: 0.4))
                            .cornerRadius(12)
                            .shadow(
                                color: Color(red: 0.0, green: 0.2, blue: 0.4).opacity(0.3),
                                radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.isLoading)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.7))
                            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                    )
                    .padding(.horizontal, 32)

                    Spacer()

                    // Register Link with prettier styling
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        NavigationLink("Sign Up") {
                            // RegisterView will be injected here
                            Text("Register View")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
}
