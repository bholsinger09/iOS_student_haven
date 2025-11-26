import Core
import SwiftUI

/// Detailed view for a single class
struct ClassDetailView: View {
    let classItem: Class
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showEditSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    Text(classItem.name)
                        .font(.title)
                        .fontWeight(.bold)

                    Text(classItem.courseCode)
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                .padding(.top)

                // Quick Info Cards
                HStack(spacing: 16) {
                    if let professor = classItem.professor {
                        InfoCard(icon: "person.fill", title: "Professor", value: professor)
                    }

                    if let location = classItem.location {
                        InfoCard(icon: "mappin.circle.fill", title: "Location", value: location)
                    }
                }
                .padding(.horizontal)

                // Schedule Section
                if !classItem.schedule.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Schedule")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(classItem.schedule) { timeSlot in
                            TimeSlotRow(timeSlot: timeSlot)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Actions Section
                VStack(spacing: 12) {
                    NavigationLink(destination: Text("Notes for \(classItem.name)")) {
                        ActionButton(icon: "note.text", title: "View Notes", color: .blue)
                    }

                    NavigationLink(destination: Text("Flashcards for \(classItem.name)")) {
                        ActionButton(
                            icon: "rectangle.stack.fill", title: "Study Flashcards", color: .green)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showEditSheet = true }) {
                    Text("Edit")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if let userId = appState.currentUser?.id {
                AddClassView(viewModel: ClassFormViewModel(
                    createClassUseCase: CreateClassUseCase(repository: appState.classRepository),
                    updateClassUseCase: UpdateClassUseCase(repository: appState.classRepository),
                    userId: userId,
                    existingClass: classItem
                ))
            }
        }
    }
}

/// Info card component
struct InfoCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

/// Time slot row component
struct TimeSlotRow: View {
    let timeSlot: Class.TimeSlot

    var body: some View {
        HStack {
            Image(systemName: "calendar")
                .foregroundColor(.blue)

            Text(timeSlot.dayOfWeek.rawValue)
                .fontWeight(.semibold)

            Spacer()

            HStack(spacing: 4) {
                Text(timeSlot.startTime, style: .time)
                Text("–")
                Text(timeSlot.endTime, style: .time)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
}

/// Action button component
struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .fontWeight(.semibold)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}
