import Core
import Foundation

/// Use case for creating a new class
final class CreateClassUseCase {
    private let repository: ClassRepositoryProtocol

    init(repository: ClassRepositoryProtocol) {
        self.repository = repository
    }

    func execute(classItem: Class) async throws -> Class {
        // Validate class data
        guard !classItem.name.isEmpty else {
            throw AppError.invalidData("Class name cannot be empty")
        }

        guard !classItem.courseCode.isEmpty else {
            throw AppError.invalidData("Course code cannot be empty")
        }

        // Validate time slots don't overlap
        try validateTimeSlots(classItem.schedule)

        return try await repository.createClass(classItem)
    }

    private func validateTimeSlots(_ timeSlots: [Class.TimeSlot]) throws {
        let sortedSlots = timeSlots.sorted { $0.startTime < $1.startTime }

        for i in 0..<sortedSlots.count {
            for j in (i + 1)..<sortedSlots.count {
                let slot1 = sortedSlots[i]
                let slot2 = sortedSlots[j]

                // Check if same day
                if slot1.dayOfWeek == slot2.dayOfWeek {
                    // Check for overlap
                    if slot1.endTime > slot2.startTime && slot1.startTime < slot2.endTime {
                        throw AppError.invalidData("Time slots cannot overlap on the same day")
                    }
                }
            }
        }
    }
}
