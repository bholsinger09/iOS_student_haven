import Core
import Foundation

/// Credentials for user login
public struct LoginCredentials: Equatable {
    public let email: String
    public let password: String

    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

/// Data required for user registration
public struct RegistrationData: Equatable {
    public let email: String
    public let password: String
    public let name: String
    public let collegeId: String?

    public init(email: String, password: String, name: String, collegeId: String? = nil) {
        self.email = email
        self.password = password
        self.name = name
        self.collegeId = collegeId
    }
}

/// Authentication session information
public struct AuthSession: Equatable {
    public let user: User
    public let token: String
    public let expiresAt: Date

    public init(user: User, token: String, expiresAt: Date) {
        self.user = user
        self.token = token
        self.expiresAt = expiresAt
    }
}
