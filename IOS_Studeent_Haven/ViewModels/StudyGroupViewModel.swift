//
//  StudyGroupViewModel.swift
//  IOS_Student_Haven
//
//  Created on 12/6/2025.
//

import Foundation
import SwiftUI

@MainActor
class StudyGroupViewModel: ObservableObject {
    @Published var studyGroups: [StudyGroup] = []
    @Published var myGroups: [StudyGroup] = []
    @Published var upcomingSessions: [StudySession] = []
    @Published var selectedGroup: StudyGroup?
    @Published var searchText = ""
    @Published var selectedClassFilter: String?
    @Published var showOnlyAvailable = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingCreateGroup = false
    @Published var showingCreateSession = false
    
    private let studyGroupManager = StudyGroupManagementUseCase()
    private let currentUserId = "currentUser" // Should come from auth
    
    init() {
        loadData()
    }
    
    // MARK: - Load Data
    func loadData() {
        isLoading = true
        
        studyGroups = studyGroupManager.getAllStudyGroups()
        myGroups = studyGroupManager.getUserStudyGroups(userId: currentUserId)
        upcomingSessions = studyGroupManager.getUpcomingSessions(forUserId: currentUserId)
        
        isLoading = false
    }
    
    // MARK: - Search and Filter
    var filteredGroups: [StudyGroup] {
        let filter = StudyGroupFilter(
            classId: selectedClassFilter,
            onlyAvailable: showOnlyAvailable,
            searchQuery: searchText
        )
        
        return studyGroupManager.searchStudyGroups(filter: filter)
    }
    
    func searchGroups() {
        studyGroups = filteredGroups
    }
    
    func filterByClass(classId: String?) {
        selectedClassFilter = classId
        searchGroups()
    }
    
    // MARK: - Group Management
    func createGroup(
        name: String,
        classId: String,
        className: String,
        description: String,
        maxMembers: Int,
        isPublic: Bool,
        tags: [String]
    ) {
        let newGroup = StudyGroup(
            name: name,
            classId: classId,
            className: className,
            description: description,
            creatorId: currentUserId,
            creatorName: "Current User", // Should come from auth
            maxMembers: maxMembers,
            isPublic: isPublic,
            tags: tags
        )
        
        let created = studyGroupManager.createStudyGroup(newGroup)
        loadData()
        selectedGroup = created
        showingCreateGroup = false
    }
    
    func updateGroup(_ group: StudyGroup) {
        studyGroupManager.updateStudyGroup(group)
        loadData()
    }
    
    func deleteGroup(id: UUID) {
        studyGroupManager.deleteStudyGroup(id: id)
        loadData()
        if selectedGroup?.id == id {
            selectedGroup = nil
        }
    }
    
    // MARK: - Membership
    func joinGroup(_ group: StudyGroup) {
        let result = studyGroupManager.joinStudyGroup(groupId: group.id, userId: currentUserId)
        
        switch result {
        case .success(let updatedGroup):
            selectedGroup = updatedGroup
            loadData()
            errorMessage = nil
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    func leaveGroup(_ group: StudyGroup) {
        let result = studyGroupManager.leaveStudyGroup(groupId: group.id, userId: currentUserId)
        
        switch result {
        case .success:
            loadData()
            if selectedGroup?.id == group.id {
                selectedGroup = nil
            }
            errorMessage = nil
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    func isUserMember(of group: StudyGroup) -> Bool {
        return group.memberIds.contains(currentUserId)
    }
    
    // MARK: - Session Management
    func createSession(
        for group: StudyGroup,
        title: String,
        description: String,
        startTime: Date,
        endTime: Date,
        location: SessionLocation,
        maxAttendees: Int?
    ) {
        let newSession = StudySession(
            groupId: group.id,
            title: title,
            description: description,
            startTime: startTime,
            endTime: endTime,
            location: location,
            attendeeIds: [currentUserId],
            maxAttendees: maxAttendees
        )
        
        let result = studyGroupManager.addSession(to: group.id, session: newSession)
        
        switch result {
        case .success(let updatedGroup):
            selectedGroup = updatedGroup
            loadData()
            showingCreateSession = false
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    func updateSession(groupId: UUID, session: StudySession) {
        studyGroupManager.updateSession(groupId: groupId, session: session)
        loadData()
    }
    
    func deleteSession(groupId: UUID, sessionId: UUID) {
        studyGroupManager.deleteSession(groupId: groupId, sessionId: sessionId)
        loadData()
    }
    
    func joinSession(groupId: UUID, session: StudySession) {
        let result = studyGroupManager.joinSession(
            groupId: groupId,
            sessionId: session.id,
            userId: currentUserId
        )
        
        switch result {
        case .success:
            loadData()
            errorMessage = nil
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Helpers
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func formatTimeRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
    
    func getGroupMemberCount(_ group: StudyGroup) -> String {
        return "\(group.memberIds.count)/\(group.maxMembers)"
    }
}
