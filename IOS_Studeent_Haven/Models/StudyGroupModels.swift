//
//  StudyGroupModels.swift
//  IOS_Student_Haven
//
//  Created on 12/6/2025.
//

import Foundation
import CoreLocation

// MARK: - Study Group
public struct StudyGroup: Identifiable, Codable {
    public let id: String
    public var name: String
    public var classId: String
    public var className: String
    public var description: String
    public var creatorId: String
    public var creatorName: String
    public var memberIds: [String]
    public var maxMembers: Int
    public var isPublic: Bool
    public var tags: [String]
    public var createdAt: Date
    public var sessions: [StudySession]
    
    public init(id: String = UUID().uuidString,
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
    
    public var isFull: Bool {
        return memberIds.count >= maxMembers
    }
    
    public var availableSpots: Int {
        return max(0, maxMembers - memberIds.count)
    }
}

// MARK: - Study Session
public struct StudySession: Identifiable, Codable {
    public let id: String
    public var groupId: String
    public var title: String
    public var description: String
    public var startTime: Date
    public var endTime: Date
    public var location: SessionLocation
    public var attendeeIds: [String]
    public var maxAttendees: Int?
    public var isRecurring: Bool
    public var recurrenceRule: RecurrenceRule?
    public var status: SessionStatus
    
    public init(id: String = UUID().uuidString,
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
    
    public var duration: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
    
    public var isUpcoming: Bool {
        return startTime > Date() && status == .scheduled
    }
    
    public var isFull: Bool {
        guard let max = maxAttendees else { return false }
        return attendeeIds.count >= max
    }
}

// MARK: - Session Location
public struct SessionLocation: Codable {
    public var name: String
    public var address: String?
    public var building: String?
    public var room: String?
    public var latitude: Double?
    public var longitude: Double?
    public var locationType: LocationType
    
    public init(name: String,
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
    
    public var fullAddress: String {
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
    
    public var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

// MARK: - Location Type
public enum LocationType: String, Codable, CaseIterable {
    case campus = "Campus"
    case library = "Library"
    case cafe = "Cafe"
    case online = "Online"
    case other = "Other"
}

// MARK: - Session Status
public enum SessionStatus: String, Codable {
    case scheduled = "Scheduled"
    case inProgress = "In Progress"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

// MARK: - Recurrence Rule
public struct RecurrenceRule: Codable {
    public var frequency: RecurrenceFrequency
    public var interval: Int // Every X days/weeks/months
    public var endDate: Date?
    
    public init(frequency: RecurrenceFrequency,
         interval: Int = 1,
         endDate: Date? = nil) {
        self.frequency = frequency
        self.interval = interval
        self.endDate = endDate
    }
}

public enum RecurrenceFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Biweekly"
    case monthly = "Monthly"
}

// MARK: - Study Group Member
public struct StudyGroupMember: Identifiable, Codable {
    public let id: String // User ID
    public var name: String
    public var email: String?
    public var major: String?
    public var year: String?
    public var joinedAt: Date
    public var role: MemberRole
    
    public init(id: String,
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

public enum MemberRole: String, Codable {
    case creator = "Creator"
    case admin = "Admin"
    case member = "Member"
}

// MARK: - Study Group Filter
public struct StudyGroupFilter {
    public var classId: String?
    public var tags: [String]
    public var maxDistance: Double? // in meters
    public var userLocation: CLLocationCoordinate2D?
    public var onlyAvailable: Bool // Not full
    public var searchQuery: String
    
    public init(classId: String? = nil,
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
