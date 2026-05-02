//
//  StudyGroupModels.swift
//  IOS_Student_Haven
//
//  Created on 12/6/2025.
//

import Foundation
import CoreLocation

// MARK: - Study Group
struct StudyGroup: Identifiable, Codable {
    let id: String
    var name: String
    var classId: String
    var className: String
    var description: String
    var creatorId: String
    var creatorName: String
    var memberIds: [String]
    var maxMembers: Int
    var isPublic: Bool
    var tags: [String]
    var createdAt: Date
    var sessions: [StudySession]
    
    init(id: String = UUID().uuidString,
         name: String,
         classId: String,
         className: String,
         description: String,
         creatorId: String,
         creatorName: String,
         memberIds: [String] = [],
         maxMembers: Int = 10,
         isPublic: Bool = true,
         tags: [String] = [],
         createdAt: Date = Date(),
         sessions: [StudySession] = []) {
        self.id = id
        self.name = name
        self.classId = classId
        self.className = className
        self.description = description
        self.creatorId = creatorId
        self.creatorName = creatorName
        self.memberIds = memberIds
        self.maxMembers = maxMembers
        self.isPublic = isPublic
        self.tags = tags
        self.createdAt = createdAt
        self.sessions = sessions
    }
    
    var isFull: Bool {
        return memberIds.count >= maxMembers
    }
    
    var availableSpots: Int {
        return max(0, maxMembers - memberIds.count)
    }
}

// MARK: - Study Session
struct StudySession: Identifiable, Codable {
    let id: String
    var groupId: String
    var title: String
    var description: String
    var startTime: Date
    var endTime: Date
    var location: SessionLocation
    var attendeeIds: [String]
    var maxAttendees: Int?
    var isRecurring: Bool
    var recurrenceRule: RecurrenceRule?
    var status: SessionStatus
    
    init(id: String = UUID().uuidString,
         groupId: String,
         title: String,
         description: String = "",
         startTime: Date,
         endTime: Date,
         location: SessionLocation,
         attendeeIds: [String] = [],
         maxAttendees: Int? = nil,
         isRecurring: Bool = false,
         recurrenceRule: RecurrenceRule? = nil,
         status: SessionStatus = .scheduled) {
        self.id = id
        self.groupId = groupId
        self.title = title
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.attendeeIds = attendeeIds
        self.maxAttendees = maxAttendees
        self.isRecurring = isRecurring
        self.recurrenceRule = recurrenceRule
        self.status = status
    }
    
    var duration: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
    
    var isUpcoming: Bool {
        return startTime > Date() && status == .scheduled
    }
    
    var isFull: Bool {
        guard let max = maxAttendees else { return false }
        return attendeeIds.count >= max
    }
}

// MARK: - Session Location
struct SessionLocation: Codable {
    var name: String
    var address: String?
    var building: String?
    var room: String?
    var latitude: Double?
    var longitude: Double?
    var locationType: LocationType
    
    init(name: String,
         address: String? = nil,
         building: String? = nil,
         room: String? = nil,
         latitude: Double? = nil,
         longitude: Double? = nil,
         locationType: LocationType = .campus) {
        self.name = name
        self.address = address
        self.building = building
        self.room = room
        self.latitude = latitude
        self.longitude = longitude
        self.locationType = locationType
    }
    
    var fullAddress: String {
        var components: [String] = [name]
        if let building = building {
            components.append(building)
        }
        if let room = room {
            components.append("Room \(room)")
        }
        if let address = address {
            components.append(address)
        }
        return components.joined(separator: ", ")
    }
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

// MARK: - Location Type
enum LocationType: String, Codable, CaseIterable {
    case campus = "Campus"
    case library = "Library"
    case cafe = "Cafe"
    case online = "Online"
    case other = "Other"
}

// MARK: - Session Status
enum SessionStatus: String, Codable {
    case scheduled = "Scheduled"
    case inProgress = "In Progress"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

// MARK: - Recurrence Rule
struct RecurrenceRule: Codable {
    var frequency: RecurrenceFrequency
    var interval: Int // Every X days/weeks/months
    var endDate: Date?
    
    init(frequency: RecurrenceFrequency,
         interval: Int = 1,
         endDate: Date? = nil) {
        self.frequency = frequency
        self.interval = interval
        self.endDate = endDate
    }
}

enum RecurrenceFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Biweekly"
    case monthly = "Monthly"
}

// MARK: - Study Group Member
struct StudyGroupMember: Identifiable, Codable {
    let id: String // User ID
    var name: String
    var email: String?
    var major: String?
    var year: String?
    var joinedAt: Date
    var role: MemberRole
    
    init(id: String,
         name: String,
         email: String? = nil,
         major: String? = nil,
         year: String? = nil,
         joinedAt: Date = Date(),
         role: MemberRole = .member) {
        self.id = id
        self.name = name
        self.email = email
        self.major = major
        self.year = year
        self.joinedAt = joinedAt
        self.role = role
    }
}

enum MemberRole: String, Codable {
    case creator = "Creator"
    case admin = "Admin"
    case member = "Member"
}

// MARK: - Study Group Filter
struct StudyGroupFilter {
    var classId: String?
    var tags: [String]
    var maxDistance: Double? // in meters
    var userLocation: CLLocationCoordinate2D?
    var onlyAvailable: Bool // Not full
    var searchQuery: String
    
    init(classId: String? = nil,
         tags: [String] = [],
         maxDistance: Double? = nil,
         userLocation: CLLocationCoordinate2D? = nil,
         onlyAvailable: Bool = false,
         searchQuery: String = "") {
        self.classId = classId
        self.tags = tags
        self.maxDistance = maxDistance
        self.userLocation = userLocation
        self.onlyAvailable = onlyAvailable
        self.searchQuery = searchQuery
    }
}
