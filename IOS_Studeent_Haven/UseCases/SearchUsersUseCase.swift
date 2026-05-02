//
//  SearchUsersUseCase.swift
//  IOS_Student_Haven
//
//  Created on 1/2/2025.
//

import Foundation

/// Use case for searching users by first name and email
public class SearchUsersUseCase {
    private let userRepository: UserRepositoryProtocol
    
    public init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    /// Search for users matching the given criteria
    /// - Parameters:
    ///   - firstName: The first name to search for (case-insensitive)
    ///   - email: The email to search for (case-insensitive, supports partial matches)
    /// - Returns: Array of matching users
    public func execute(firstName: String, email: String) async throws -> [User] {
        // Validate input
        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard !trimmedFirstName.isEmpty || !trimmedEmail.isEmpty else {
            throw SearchUsersError.invalidSearchCriteria
        }
        
        return try await userRepository.searchUsers(firstName: trimmedFirstName, email: trimmedEmail)
    }
}

/// Errors that can occur during user search
public enum SearchUsersError: Error, LocalizedError {
    case invalidSearchCriteria
    case networkError
    
    public var errorDescription: String? {
        switch self {
        case .invalidSearchCriteria:
            return "Please provide at least a first name or email to search"
        case .networkError:
            return "Unable to search for users. Please check your connection"
        }
    }
}
