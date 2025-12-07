import Combine
import Core
import Foundation

/// ViewModel for Add/Edit Class screen
@MainActor
final class ClassFormViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var courseCode: String = ""
    @Published var professor: String = ""
    @Published var location: String = ""
    @Published var timeSlots: [Class.TimeSlot] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isSaved: Bool = false

    private let createClassUseCase: IOS_Student_Haven.CreateClassUseCase
    private let updateClassUseCase: IOS_Student_Haven.UpdateClassUseCase
    private let userId: String
    fileprivate(set) var existingClass: Class?

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !courseCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(
        createClassUseCase: IOS_Student_Haven.CreateClassUseCase,
        updateClassUseCase: IOS_Student_Haven.UpdateClassUseCase,
        userId: String,
        existingClass: Class? = nil
    ) {
        self.createClassUseCase = createClassUseCase
        self.updateClassUseCase = updateClassUseCase
        self.userId = userId
        self.existingClass = existingClass

        if let existing = existingClass {
            self.name = existing.name
            self.courseCode = existing.courseCode
            self.professor = existing.professor ?? ""
            self.location = existing.location ?? ""
            self.timeSlots = existing.schedule
        }
    }

    func save() async {
        guard isFormValid else {
            errorMessage = "Please fill in class name and course code"
            return
        }
        
        isLoading = true
        errorMessage = nil

        do {
            let classItem = Class(
                id: existingClass?.id ?? UUID().uuidString,
                userId: userId,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                courseCode: courseCode.trimmingCharacters(in: .whitespacesAndNewlines),
                schedule: timeSlots,
                professor: professor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : professor.trimmingCharacters(in: .whitespacesAndNewlines),
                location: location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : location.trimmingCharacters(in: .whitespacesAndNewlines)
            )

            if existingClass != nil {
                _ = try await updateClassUseCase.execute(classItem: classItem)
            } else {
                _ = try await createClassUseCase.execute(classItem: classItem)
            }

            isSaved = true

            // Notify that a class was saved
            NotificationCenter.default.post(
                name: NSNotification.Name("ClassDidSave"),
                object: nil
            )
        } catch let error as AppError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to save class"
        }

        isLoading = false
    }

    func addTimeSlot(_ timeSlot: Class.TimeSlot) {
        timeSlots.append(timeSlot)
    }

    func removeTimeSlot(at offsets: IndexSet) {
        timeSlots.remove(atOffsets: offsets)
    }
}
