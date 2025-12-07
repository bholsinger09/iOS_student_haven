import Authentication
import Core
import Foundation

/// Mock implementation of AuthRepository for development and testing
public final class MockAuthRepositoryImpl: AuthRepositoryProtocol {
    private var currentSession: AuthSession?
    private var users: [String: (User, String)] = [:]  // email -> (user, password)

    public init() {
        // Pre-populate with a default test user for demos and code reviews
        let testUser = User(
            id: "demo-user-123",
            email: "demo@studyhaven.com",
            name: "Demo User",
            collegeId: "Boise State University"
        )
        users["demo@studyhaven.com"] = (testUser, "demo123")
    }

    public func login(credentials: LoginCredentials) async throws -> AuthSession {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        guard let (user, password) = users[credentials.email] else {
            throw AppError.invalidCredentials
        }

        guard password == credentials.password else {
            throw AppError.invalidCredentials
        }

        let session = AuthSession(
            user: user,
            token: UUID().uuidString,
            expiresAt: Date().addingTimeInterval(3600)
        )

        currentSession = session
        return session
    }

    public func register(data: RegistrationData) async throws -> AuthSession {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        guard users[data.email] == nil else {
            throw AppError.emailAlreadyExists
        }

        let user = User(
            id: UUID().uuidString,
            email: data.email,
            name: data.name,
            collegeId: data.collegeId
        )

        users[data.email] = (user, data.password)

        let session = AuthSession(
            user: user,
            token: UUID().uuidString,
            expiresAt: Date().addingTimeInterval(3600)
        )

        currentSession = session
        return session
    }

    public func logout() async throws {
        currentSession = nil
    }

    public func getCurrentSession() async -> AuthSession? {
        return currentSession
    }

    public func refreshToken() async throws -> AuthSession {
        guard let session = currentSession else {
            throw AppError.unauthorized
        }

        let newSession = AuthSession(
            user: session.user,
            token: UUID().uuidString,
            expiresAt: Date().addingTimeInterval(3600)
        )

        currentSession = newSession
        return newSession
    }
    
    public func deleteAccount() async throws {
        guard let session = currentSession else {
            throw AppError.unauthorized
        }
        
        // Remove user from storage
        users.removeValue(forKey: session.user.email)
        
        // Clear session
        currentSession = nil
    }
}
