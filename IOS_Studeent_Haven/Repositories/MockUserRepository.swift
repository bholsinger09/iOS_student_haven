//
//  MockUserRepository.swift
//  IOS_Student_Haven
//
//  Created on 1/2/2025.
//

import Foundation

/// Mock implementation of UserRepositoryProtocol for testing
public class MockUserRepository: UserRepositoryProtocol {
    public var mockUsers: [User] = []
    public var shouldThrowError = false
    public var errorToThrow: Error?
    
    public init() {}
    
    public func searchUsers(firstName: String, email: String) async throws -> [User] {
        if shouldThrowError {
            throw errorToThrow ?? SearchUsersError.networkError
        }
        
        return mockUsers.filter { user in
            let nameMatches = firstName.isEmpty || user.name.localizedCaseInsensitiveContains(firstName)
            let emailMatches = email.isEmpty || user.email.localizedCaseInsensitiveContains(email)
            return (firstName.isEmpty || nameMatches) && (email.isEmpty || emailMatches)
        }
    }
    
    public func getUser(byId userId: String) async throws -> User? {
        if shouldThrowError {
            throw errorToThrow ?? SearchUsersError.networkError
        }
        
        return mockUsers.first { $0.id == userId }
    }
}
