import Core
import Foundation

/// Use case for updating an existing class
final class UpdateClassUseCase {
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

        return try await repository.updateClass(classItem)
    }
}
