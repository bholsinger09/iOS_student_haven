//
//  InviteUserToGroupUseCase.swift
//  IOS_Student_Haven
//
//  Created on 1/2/2025.
//

import Foundation

/// Use case for inviting a user to join a study group
public class InviteUserToGroupUseCase {
    private let studyGroupManager: StudyGroupManagementUseCase
    
    public init(studyGroupManager: StudyGroupManagementUseCase) {
        self.studyGroupManager = studyGroupManager
    }
    
    /// Invite a user to join a study group
    /// - Parameters:
    ///   - userId: The ID of the user to invite
    ///   - groupId: The ID of the study group
    ///   - invitingUserId: The ID of the user sending the invitation
    /// - Returns: The updated study group
    public func execute(userId: String, groupId: String, invitingUserId: String) -> Result<StudyGroup, InviteUserError> {
        // Get the study group
        guard let group = studyGroupManager.getStudyGroup(id: groupId) else {
            return .failure(.groupNotFound)
        }
        
        // Verify the inviting user is a member or creator
        guard group.memberIds.contains(invitingUserId) || group.creatorId == invitingUserId else {
            return .failure(.notAuthorized)
        }
        
        // Check if user is already a member
        if group.memberIds.contains(userId) {
            return .failure(.alreadyMember)
        }
        
        // Check if group is full
        if group.isFull {
            return .failure(.groupFull)
        }
        
        // Add the user to the group
        let result = studyGroupManager.joinStudyGroup(groupId: groupId, userId: userId)
        
        switch result {
        case .success(let updatedGroup):
            return .success(updatedGroup)
        case .failure(let error):
            // Map StudyGroupError to InviteUserError
            switch error {
            case .groupNotFound:
                return .failure(.groupNotFound)
            case .groupFull:
                return .failure(.groupFull)
            case .alreadyMember:
                return .failure(.alreadyMember)
            default:
                return .failure(.unknownError)
            }
        }
    }
}

/// Errors that can occur when inviting a user to a group
public enum InviteUserError: Error, LocalizedError {
    case groupNotFound
    case notAuthorized
    case alreadyMember
    case groupFull
    case unknownError
    
    public var errorDescription: String? {
        switch self {
        case .groupNotFound:
            return "Study group not found"
        case .notAuthorized:
            return "You must be a member of the group to invite others"
        case .alreadyMember:
            return "This user is already a member of the group"
        case .groupFull:
            return "This group is full and cannot accept more members"
        case .unknownError:
            return "An unexpected error occurred"
        }
    }
}
