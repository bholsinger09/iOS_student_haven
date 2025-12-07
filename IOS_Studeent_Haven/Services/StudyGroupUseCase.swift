//
//  StudyGroupUseCase.swift
//  IOS_Student_Haven
//
//  Created on 12/6/2025.
//

import Foundation
import CoreLocation

// MARK: - Study Group Management Use Case
class StudyGroupManagementUseCase {
    private var studyGroups: [StudyGroup] = []
    private var userStudyGroups: Set<UUID> = [] // Groups the user is a member of
    
    init() {
        loadStudyGroups()
        loadUserGroups()
    }
    
    // MARK: - Group Management
    func createStudyGroup(_ group: StudyGroup) -> StudyGroup {
        var newGroup = group
        newGroup.memberIds.append(group.creatorId)
        studyGroups.append(newGroup)
        userStudyGroups.insert(newGroup.id)
        saveStudyGroups()
        return newGroup
    }
    
    func updateStudyGroup(_ group: StudyGroup) {
        if let index = studyGroups.firstIndex(where: { $0.id == group.id }) {
            studyGroups[index] = group
            saveStudyGroups()
        }
    }
    
    func deleteStudyGroup(id: UUID) {
        studyGroups.removeAll { $0.id == id }
        userStudyGroups.remove(id)
        saveStudyGroups()
    }
    
    func getStudyGroup(id: UUID) -> StudyGroup? {
        return studyGroups.first { $0.id == id }
    }
    
    func getAllStudyGroups() -> [StudyGroup] {
        return studyGroups
    }
    
    // MARK: - Search and Filter
    func searchStudyGroups(filter: StudyGroupFilter) -> [StudyGroup] {
        var filtered = studyGroups
        
        // Filter by class
        if let classId = filter.classId {
            filtered = filtered.filter { $0.classId == classId }
        }
        
        // Filter by availability
        if filter.onlyAvailable {
            filtered = filtered.filter { !$0.isFull }
        }
        
        // Filter by search query
        if !filter.searchQuery.isEmpty {
            let query = filter.searchQuery.lowercased()
            filtered = filtered.filter {
                $0.name.lowercased().contains(query) ||
                $0.className.lowercased().contains(query) ||
                $0.description.lowercased().contains(query)
            }
        }
        
        // Filter by tags
        if !filter.tags.isEmpty {
            filtered = filtered.filter { group in
                !Set(group.tags).isDisjoint(with: Set(filter.tags))
            }
        }
        
        return filtered
    }
    
    func getStudyGroupsForClass(classId: String) -> [StudyGroup] {
        return studyGroups.filter { $0.classId == classId }
    }
    
    func getUserStudyGroups(userId: String) -> [StudyGroup] {
        return studyGroups.filter { $0.memberIds.contains(userId) }
    }
    
    // MARK: - Membership Management
    func joinStudyGroup(groupId: UUID, userId: String) -> Result<StudyGroup, StudyGroupError> {
        guard let index = studyGroups.firstIndex(where: { $0.id == groupId }) else {
            return .failure(.groupNotFound)
        }
        
        var group = studyGroups[index]
        
        if group.memberIds.contains(userId) {
            return .failure(.alreadyMember)
        }
        
        if group.isFull {
            return .failure(.groupFull)
        }
        
        group.memberIds.append(userId)
        studyGroups[index] = group
        userStudyGroups.insert(groupId)
        saveStudyGroups()
        
        return .success(group)
    }
    
    func leaveStudyGroup(groupId: UUID, userId: String) -> Result<Void, StudyGroupError> {
        guard let index = studyGroups.firstIndex(where: { $0.id == groupId }) else {
            return .failure(.groupNotFound)
        }
        
        var group = studyGroups[index]
        
        if !group.memberIds.contains(userId) {
            return .failure(.notMember)
        }
        
        // Creator cannot leave (must transfer ownership or delete group)
        if group.creatorId == userId {
            return .failure(.creatorCannotLeave)
        }
        
        group.memberIds.removeAll { $0 == userId }
        studyGroups[index] = group
        userStudyGroups.remove(groupId)
        saveStudyGroups()
        
        return .success(())
    }
    
    // MARK: - Session Management
    func addSession(to groupId: UUID, session: StudySession) -> Result<StudyGroup, StudyGroupError> {
        guard let index = studyGroups.firstIndex(where: { $0.id == groupId }) else {
            return .failure(.groupNotFound)
        }
        
        var group = studyGroups[index]
        group.sessions.append(session)
        studyGroups[index] = group
        saveStudyGroups()
        
        return .success(group)
    }
    
    func updateSession(groupId: UUID, session: StudySession) {
        guard let groupIndex = studyGroups.firstIndex(where: { $0.id == groupId }),
              let sessionIndex = studyGroups[groupIndex].sessions.firstIndex(where: { $0.id == session.id }) else {
            return
        }
        
        studyGroups[groupIndex].sessions[sessionIndex] = session
        saveStudyGroups()
    }
    
    func deleteSession(groupId: UUID, sessionId: UUID) {
        guard let groupIndex = studyGroups.firstIndex(where: { $0.id == groupId }) else {
            return
        }
        
        studyGroups[groupIndex].sessions.removeAll { $0.id == sessionId }
        saveStudyGroups()
    }
    
    func getUpcomingSessions(forUserId userId: String) -> [StudySession] {
        let userGroups = studyGroups.filter { $0.memberIds.contains(userId) }
        var allSessions: [StudySession] = []
        
        for group in userGroups {
            let upcomingSessions = group.sessions.filter { $0.isUpcoming }
            allSessions.append(contentsOf: upcomingSessions)
        }
        
        return allSessions.sorted { $0.startTime < $1.startTime }
    }
    
    func joinSession(groupId: UUID, sessionId: UUID, userId: String) -> Result<StudySession, StudyGroupError> {
        guard let groupIndex = studyGroups.firstIndex(where: { $0.id == groupId }),
              let sessionIndex = studyGroups[groupIndex].sessions.firstIndex(where: { $0.id == sessionId }) else {
            return .failure(.sessionNotFound)
        }
        
        var session = studyGroups[groupIndex].sessions[sessionIndex]
        
        if session.isFull {
            return .failure(.sessionFull)
        }
        
        if !session.attendeeIds.contains(userId) {
            session.attendeeIds.append(userId)
            studyGroups[groupIndex].sessions[sessionIndex] = session
            saveStudyGroups()
        }
        
        return .success(session)
    }
    
    // MARK: - Persistence
    private func saveStudyGroups() {
        if let encoded = try? JSONEncoder().encode(studyGroups) {
            UserDefaults.standard.set(encoded, forKey: "savedStudyGroups")
        }
        if let encodedUserGroups = try? JSONEncoder().encode(Array(userStudyGroups)) {
            UserDefaults.standard.set(encodedUserGroups, forKey: "userStudyGroups")
        }
    }
    
    private func loadStudyGroups() {
        if let data = UserDefaults.standard.data(forKey: "savedStudyGroups"),
           let decoded = try? JSONDecoder().decode([StudyGroup].self, from: data) {
            studyGroups = decoded
        } else {
            // Load sample data for demo
            loadSampleData()
        }
    }
    
    private func loadUserGroups() {
        if let data = UserDefaults.standard.data(forKey: "userStudyGroups"),
           let decoded = try? JSONDecoder().decode([UUID].self, from: data) {
            userStudyGroups = Set(decoded)
        }
    }
    
    private func loadSampleData() {
        // Sample study groups for demonstration
        let sampleGroups = [
            StudyGroup(
                name: "Calculus Study Squad",
                classId: "MATH101",
                className: "Calculus I",
                description: "Weekly study sessions for calc homework and exam prep",
                creatorId: "user1",
                creatorName: "Alex Johnson",
                memberIds: ["user1", "user2", "user3"],
                maxMembers: 8,
                tags: ["Math", "Homework Help", "Exam Prep"]
            ),
            StudyGroup(
                name: "CS Project Team",
                classId: "CS201",
                className: "Data Structures",
                description: "Working on final project together",
                creatorId: "user2",
                creatorName: "Sarah Chen",
                memberIds: ["user2", "user4"],
                maxMembers: 4,
                tags: ["Computer Science", "Project"]
            )
        ]
        
        studyGroups = sampleGroups
        saveStudyGroups()
    }
}

// MARK: - Study Group Errors
enum StudyGroupError: LocalizedError {
    case groupNotFound
    case groupFull
    case alreadyMember
    case notMember
    case creatorCannotLeave
    case sessionNotFound
    case sessionFull
    
    var errorDescription: String? {
        switch self {
        case .groupNotFound:
            return "Study group not found"
        case .groupFull:
            return "This study group is full"
        case .alreadyMember:
            return "You are already a member of this group"
        case .notMember:
            return "You are not a member of this group"
        case .creatorCannotLeave:
            return "Group creator cannot leave. Transfer ownership or delete the group."
        case .sessionNotFound:
            return "Study session not found"
        case .sessionFull:
            return "This study session is full"
        }
    }
}
