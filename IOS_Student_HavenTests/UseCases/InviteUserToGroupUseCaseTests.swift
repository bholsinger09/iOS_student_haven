//
//  InviteUserToGroupUseCaseTests.swift
//  IOS_Student_HavenTests
//
//  Created on 1/2/2025.
//

import XCTest
@testable import IOS_Student_Haven

final class InviteUserToGroupUseCaseTests: XCTestCase {
    var sut: InviteUserToGroupUseCase!
    var mockStudyGroupManager: StudyGroupManagementUseCase!
    var testGroup: StudyGroup!
    
    override func setUp() {
        super.setUp()
        mockStudyGroupManager = StudyGroupManagementUseCase()
        sut = InviteUserToGroupUseCase(studyGroupManager: mockStudyGroupManager)
        
        // Create a test group
        testGroup = StudyGroup(
            name: "Test Study Group",
            classId: "CS101",
            className: "Computer Science",
            description: "A test group",
            creatorId: "creator123",
            creatorName: "Test Creator",
            memberIds: ["member1"],  // createStudyGroup will add creator123
            maxMembers: 5,
            tags: ["testing"]
        )
        
        // Add it to the manager
        testGroup = mockStudyGroupManager.createStudyGroup(testGroup)
    }
    
    override func tearDown() {
        sut = nil
        mockStudyGroupManager = nil
        testGroup = nil
        super.tearDown()
    }
    
    // MARK: - Tests for successful invitations
    
    func testInviteUser_AsCreator_Succeeds() {
        // Given
        let newUserId = "newUser123"
        let creatorId = testGroup.creatorId
        
        // When
        let result = sut.execute(userId: newUserId, groupId: testGroup.id, invitingUserId: creatorId)
        
        // Then
        switch result {
        case .success(let updatedGroup):
            XCTAssertTrue(updatedGroup.memberIds.contains(newUserId), "New user should be added to group")
            XCTAssertEqual(updatedGroup.memberIds.count, 3, "Group should have 3 members now")
        case .failure(let error):
            XCTFail("Should succeed but got error: \(error)")
        }
    }
    
    func testInviteUser_AsMember_Succeeds() {
        // Given
        let newUserId = "newUser123"
        let existingMemberId = "member1"
        
        // When
        let result = sut.execute(userId: newUserId, groupId: testGroup.id, invitingUserId: existingMemberId)
        
        // Then
        switch result {
        case .success(let updatedGroup):
            XCTAssertTrue(updatedGroup.memberIds.contains(newUserId), "New user should be added to group")
        case .failure(let error):
            XCTFail("Should succeed but got error: \(error)")
        }
    }
    
    // MARK: - Tests for authorization errors
    
    func testInviteUser_AsNonMember_Fails() {
        // Given
        let newUserId = "newUser123"
        let nonMemberId = "outsider456"
        
        // When
        let result = sut.execute(userId: newUserId, groupId: testGroup.id, invitingUserId: nonMemberId)
        
        // Then
        switch result {
        case .success:
            XCTFail("Should fail with notAuthorized error")
        case .failure(let error):
            XCTAssertEqual(error, .notAuthorized)
        }
    }
    
    // MARK: - Tests for duplicate member errors
    
    func testInviteUser_AlreadyMember_Fails() {
        // Given - member1 is already in the group
        let existingMemberId = "member1"
        
        // When
        let result = sut.execute(userId: existingMemberId, groupId: testGroup.id, invitingUserId: testGroup.creatorId)
        
        // Then
        switch result {
        case .success:
            XCTFail("Should fail with alreadyMember error")
        case .failure(let error):
            XCTAssertEqual(error, .alreadyMember)
        }
    }
    
    // MARK: - Tests for group capacity errors
    
    func testInviteUser_WhenGroupFull_Fails() {
        // Given - Fill the group to max capacity (5 members)
        _ = mockStudyGroupManager.joinStudyGroup(groupId: testGroup.id, userId: "user2")
        _ = mockStudyGroupManager.joinStudyGroup(groupId: testGroup.id, userId: "user3")
        _ = mockStudyGroupManager.joinStudyGroup(groupId: testGroup.id, userId: "user4")
        
        // Verify group is now full
        let fullGroup = mockStudyGroupManager.getStudyGroup(id: testGroup.id)!
        XCTAssertTrue(fullGroup.isFull, "Group should be full")
        
        // When - Try to add one more user
        let result = sut.execute(userId: "user5", groupId: testGroup.id, invitingUserId: testGroup.creatorId)
        
        // Then
        switch result {
        case .success:
            XCTFail("Should fail with groupFull error")
        case .failure(let error):
            XCTAssertEqual(error, .groupFull)
        }
    }
    
    // MARK: - Tests for invalid group
    
    func testInviteUser_GroupNotFound_Fails() {
        // Given
        let invalidGroupId = "nonexistent-group-id"
        
        // When
        let result = sut.execute(userId: "user123", groupId: invalidGroupId, invitingUserId: testGroup.creatorId)
        
        // Then
        switch result {
        case .success:
            XCTFail("Should fail with groupNotFound error")
        case .failure(let error):
            XCTAssertEqual(error, .groupNotFound)
        }
    }
    
    // MARK: - Tests for error descriptions
    
    func testErrorDescriptions_AreProvided() {
        let errors: [InviteUserError] = [
            .groupNotFound,
            .notAuthorized,
            .alreadyMember,
            .groupFull,
            .unknownError
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription, "Error \(error) should have a description")
            XCTAssertFalse(error.errorDescription!.isEmpty, "Error description should not be empty")
        }
    }
}
