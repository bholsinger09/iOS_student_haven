import Core
import SwiftUI

/// View for adding or editing a class
struct AddClassView: View {
    @StateObject private var viewModel: ClassFormViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showingTimeSlotPicker = false
    
    private var isEditing: Bool {
        viewModel.existingClass != nil
    }

    init(viewModel: ClassFormViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                // Basic Information
                Section("Class Information") {
                    TextField("Class Name", text: $viewModel.name)
                        .textInputAutocapitalization(.words)

                    TextField("Course Code", text: $viewModel.courseCode)
                        .textInputAutocapitalization(.characters)

                    TextField("Professor (Optional)", text: $viewModel.professor)
                        .textInputAutocapitalization(.words)

                    TextField("Location (Optional)", text: $viewModel.location)
                        .textInputAutocapitalization(.words)
                }

                // Schedule Section
                Section("Schedule") {
                    if viewModel.timeSlots.isEmpty {
                        Text("No time slots added")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(viewModel.timeSlots) { timeSlot in
                            TimeSlotCell(timeSlot: timeSlot)
                        }
                        .onDelete { indexSet in
                            viewModel.removeTimeSlot(at: indexSet)
                        }
                    }

                    Button(action: { showingTimeSlotPicker = true }) {
                        Label("Add Time Slot", systemImage: "plus.circle.fill")
                    }
                }

                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Class" : "Add Class")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.save()
                        }
                    }
                    .disabled(viewModel.isLoading || !viewModel.isFormValid)
                }
            }
            .sheet(isPresented: $showingTimeSlotPicker) {
                TimeSlotPickerView { timeSlot in
                    viewModel.addTimeSlot(timeSlot)
                    showingTimeSlotPicker = false
                }
            }
            .onChange(of: viewModel.isSaved) { isSaved in
                if isSaved {
                    dismiss()
                }
            }
        }
    }
}

/// Cell for displaying a time slot
struct TimeSlotCell: View {
    let timeSlot: Class.TimeSlot

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(timeSlot.dayOfWeek.rawValue)
                .font(.subheadline)
                .fontWeight(.semibold)

            HStack {
                Text(timeSlot.startTime, style: .time)
                Text("–")
                Text(timeSlot.endTime, style: .time)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
}

/// Time slot picker view
struct TimeSlotPickerView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDay: DayOfWeek = .monday
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)

    let onSave: (Class.TimeSlot) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Day of Week") {
                    Picker("Day", selection: $selectedDay) {
                        ForEach(DayOfWeek.allCases, id: \.self) { day in
                            Text(day.rawValue).tag(day)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section("Time") {
                    DatePicker(
                        "Start Time", selection: $startTime, displayedComponents: .hourAndMinute)

                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                }
            }
            .navigationTitle("Add Time Slot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let timeSlot = Class.TimeSlot(
                            dayOfWeek: selectedDay,
                            startTime: startTime,
                            endTime: endTime
                        )
                        onSave(timeSlot)
                    }
                }
            }
        }
    }
}
