//
//  UserRepositoryProtocol.swift
//  IOS_Student_Haven
//
//  Created on 1/2/2025.
//

import Foundation

/// Protocol for user data operations
public protocol UserRepositoryProtocol {
    /// Search for users by first name and email
    /// - Parameters:
    ///   - firstName: The first name to search for
    ///   - email: The email to search for
    /// - Returns: Array of matching users
    func searchUsers(firstName: String, email: String) async throws -> [User]
    
    /// Get a user by ID
    /// - Parameter userId: The ID of the user to retrieve
    /// - Returns: The user if found, nil otherwise
    func getUser(byId userId: String) async throws -> User?
}
