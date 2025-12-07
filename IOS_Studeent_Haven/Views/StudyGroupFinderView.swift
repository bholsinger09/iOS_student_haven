//
//  StudyGroupFinderView.swift
//  IOS_Student_Haven
//
//  Created on 12/6/2025.
//

import SwiftUI
import MapKit

struct StudyGroupFinderView: View {
    @StateObject private var viewModel = StudyGroupViewModel()
    @State private var showingFilter = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search groups...", text: $viewModel.searchText)
                        .onChange(of: viewModel.searchText) { _ in
                            viewModel.searchGroups()
                        }
                    
                    if !viewModel.searchText.isEmpty {
                        Button {
                            viewModel.searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(12)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(
                            title: "Available Only",
                            isSelected: viewModel.showOnlyAvailable
                        ) {
                            viewModel.showOnlyAvailable.toggle()
                            viewModel.searchGroups()
                        }
                        
                        Button {
                            showingFilter = true
                        } label: {
                            HStack {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                Text("More Filters")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Content
                TabView {
                    AllGroupsView(viewModel: viewModel)
                        .tabItem {
                            Label("Discover", systemImage: "magnifyingglass")
                        }
                    
                    MyGroupsView(viewModel: viewModel)
                        .tabItem {
                            Label("My Groups", systemImage: "person.2.fill")
                        }
                    
                    UpcomingSessionsView(viewModel: viewModel)
                        .tabItem {
                            Label("Sessions", systemImage: "calendar")
                        }
                }
            }
            .navigationTitle("Study Groups")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingCreateGroup = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingCreateGroup) {
                CreateGroupView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingFilter) {
                FilterView(viewModel: viewModel)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), presenting: viewModel.errorMessage) { _ in
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: { message in
                Text(message)
            }
        }
    }
}

// MARK: - All Groups View
struct AllGroupsView: View {
    @ObservedObject var viewModel: StudyGroupViewModel
    
    var body: some View {
        ScrollView {
            if viewModel.filteredGroups.isEmpty {
                EmptyStateView(
                    icon: "person.3",
                    title: "No Study Groups",
                    message: "Create a group or adjust your filters"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredGroups) { group in
                        NavigationLink(destination: StudyGroupDetailView(group: group, viewModel: viewModel)) {
                            StudyGroupCard(group: group, viewModel: viewModel)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Study Group Card
struct StudyGroupCard: View {
    let group: StudyGroup
    @ObservedObject var viewModel: StudyGroupViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.headline)
                    
                    Text(group.className)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                if viewModel.isUserMember(of: group) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            Text(group.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .font(.caption)
                    Text(viewModel.getGroupMemberCount(group))
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
                Spacer()
                
                if !group.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(group.tags.prefix(3), id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
            }
            
            if group.isFull {
                Text("Group Full")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

// MARK: - Study Group Detail View
struct StudyGroupDetailView: View {
    let group: StudyGroup
    @ObservedObject var viewModel: StudyGroupViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                Text(group.className)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                Text(group.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(group.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                HStack {
                    Label(viewModel.getGroupMemberCount(group), systemImage: "person.2")
                    
                    Spacer()
                    
                    if group.isPublic {
                        Label("Public", systemImage: "globe")
                    } else {
                        Label("Private", systemImage: "lock")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                // Tags
                if !group.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(group.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
                
                // Action Button
                if viewModel.isUserMember(of: group) {
                    Button {
                        viewModel.leaveGroup(group)
                    } label: {
                        Text("Leave Group")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(10)
                    }
                } else {
                    Button {
                        viewModel.joinGroup(group)
                    } label: {
                        Text(group.isFull ? "Group Full" : "Join Group")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(group.isFull ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(group.isFull)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            
            // Tabs
            Picker("View", selection: $selectedTab) {
                Text("Sessions").tag(0)
                Text("Members").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Content
            TabView(selection: $selectedTab) {
                GroupSessionsView(group: group, viewModel: viewModel)
                    .tag(0)
                
                GroupMembersView(group: group)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Group Sessions View
struct GroupSessionsView: View {
    let group: StudyGroup
    @ObservedObject var viewModel: StudyGroupViewModel
    
    var body: some View {
        ScrollView {
            if group.sessions.isEmpty {
                EmptyStateView(
                    icon: "calendar",
                    title: "No Sessions Yet",
                    message: "Schedule a study session with your group"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(group.sessions) { session in
                        SessionCard(session: session, groupId: group.id, viewModel: viewModel)
                    }
                }
                .padding()
            }
            
            if viewModel.isUserMember(of: group) {
                Button {
                    viewModel.selectedGroup = group
                    viewModel.showingCreateSession = true
                } label: {
                    Label("Schedule Session", systemImage: "plus.circle")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .sheet(isPresented: $viewModel.showingCreateSession) {
            if let selectedGroup = viewModel.selectedGroup {
                CreateSessionView(group: selectedGroup, viewModel: viewModel)
            }
        }
    }
}

// MARK: - Session Card
struct SessionCard: View {
    let session: StudySession
    let groupId: UUID
    @ObservedObject var viewModel: StudyGroupViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title)
                        .font(.headline)
                    
                    Text(session.status.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(4)
                }
                
                Spacer()
                
                if session.isUpcoming {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                }
            }
            
            if !session.description.isEmpty {
                Text(session.description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Label(viewModel.formatTimeRange(start: session.startTime, end: session.endTime), systemImage: "clock")
                Label(session.location.fullAddress, systemImage: "location")
                
                if let max = session.maxAttendees {
                    Label("\(session.attendeeIds.count)/\(max) attending", systemImage: "person.2")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            if session.isUpcoming && !session.isFull {
                Button {
                    viewModel.joinSession(groupId: groupId, session: session)
                } label: {
                    Text("Join Session")
                        .font(.caption)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.tertiarySystemBackground))
        )
    }
    
    var statusColor: Color {
        switch session.status {
        case .scheduled: return .blue
        case .inProgress: return .green
        case .completed: return .gray
        case .cancelled: return .red
        }
    }
}

// MARK: - Group Members View
struct GroupMembersView: View {
    let group: StudyGroup
    
    var body: some View {
        List {
            ForEach(group.memberIds, id: \.self) { memberId in
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text(memberId == group.creatorId ? "\(memberId) (Creator)" : memberId)
                            .font(.headline)
                        
                        Text("Member")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - My Groups View
struct MyGroupsView: View {
    @ObservedObject var viewModel: StudyGroupViewModel
    
    var body: some View {
        ScrollView {
            if viewModel.myGroups.isEmpty {
                EmptyStateView(
                    icon: "person.2.slash",
                    title: "No Groups Yet",
                    message: "Join or create a study group to get started"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.myGroups) { group in
                        NavigationLink(destination: StudyGroupDetailView(group: group, viewModel: viewModel)) {
                            StudyGroupCard(group: group, viewModel: viewModel)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Upcoming Sessions View
struct UpcomingSessionsView: View {
    @ObservedObject var viewModel: StudyGroupViewModel
    
    var body: some View {
        ScrollView {
            if viewModel.upcomingSessions.isEmpty {
                EmptyStateView(
                    icon: "calendar.badge.exclamationmark",
                    title: "No Upcoming Sessions",
                    message: "Schedule a session with your study groups"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.upcomingSessions) { session in
                        if let group = viewModel.myGroups.first(where: { $0.id == session.groupId }) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(group.name)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                
                                SessionCard(session: session, groupId: group.id, viewModel: viewModel)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(UIColor.secondarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - Create Group View
struct CreateGroupView: View {
    @ObservedObject var viewModel: StudyGroupViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var classId = ""
    @State private var className = ""
    @State private var description = ""
    @State private var maxMembers = 10
    @State private var isPublic = true
    @State private var tags = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Group Info") {
                    TextField("Group Name", text: $name)
                    TextField("Class ID", text: $classId)
                    TextField("Class Name", text: $className)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Settings") {
                    Stepper("Max Members: \(maxMembers)", value: $maxMembers, in: 2...50)
                    Toggle("Public Group", isOn: $isPublic)
                }
                
                Section("Tags") {
                    TextField("Tags (comma separated)", text: $tags)
                    Text("e.g., Exam Prep, Homework Help, Project")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Create Study Group")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let tagArray = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        
                        viewModel.createGroup(
                            name: name,
                            classId: classId,
                            className: className,
                            description: description,
                            maxMembers: maxMembers,
                            isPublic: isPublic,
                            tags: tagArray
                        )
                        dismiss()
                    }
                    .disabled(name.isEmpty || classId.isEmpty || className.isEmpty)
                }
            }
        }
    }
}

// MARK: - Create Session View
struct CreateSessionView: View {
    let group: StudyGroup
    @ObservedObject var viewModel: StudyGroupViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    @State private var locationName = ""
    @State private var building = ""
    @State private var room = ""
    @State private var locationType: LocationType = .library
    @State private var hasMaxAttendees = false
    @State private var maxAttendees = 10
    
    var body: some View {
        NavigationView {
            Form {
                Section("Session Info") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("Time") {
                    DatePicker("Start Time", selection: $startTime)
                    DatePicker("End Time", selection: $endTime)
                }
                
                Section("Location") {
                    Picker("Type", selection: $locationType) {
                        ForEach(LocationType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField("Location Name", text: $locationName)
                    TextField("Building (optional)", text: $building)
                    TextField("Room (optional)", text: $room)
                }
                
                Section("Attendees") {
                    Toggle("Limit Attendees", isOn: $hasMaxAttendees)
                    
                    if hasMaxAttendees {
                        Stepper("Max: \(maxAttendees)", value: $maxAttendees, in: 2...50)
                    }
                }
            }
            .navigationTitle("Schedule Session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let location = SessionLocation(
                            name: locationName,
                            building: building.isEmpty ? nil : building,
                            room: room.isEmpty ? nil : room,
                            locationType: locationType
                        )
                        
                        viewModel.createSession(
                            for: group,
                            title: title,
                            description: description,
                            startTime: startTime,
                            endTime: endTime,
                            location: location,
                            maxAttendees: hasMaxAttendees ? maxAttendees : nil
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty || locationName.isEmpty || endTime <= startTime)
                }
            }
        }
    }
}

// MARK: - Filter View
struct FilterView: View {
    @ObservedObject var viewModel: StudyGroupViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Availability") {
                    Toggle("Show Only Available Groups", isOn: $viewModel.showOnlyAvailable)
                }
                
                Section("Class Filter") {
                    Button(viewModel.selectedClassFilter == nil ? "All Classes" : viewModel.selectedClassFilter!) {
                        // Would show class picker
                    }
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        viewModel.searchGroups()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    StudyGroupFinderView()
}
