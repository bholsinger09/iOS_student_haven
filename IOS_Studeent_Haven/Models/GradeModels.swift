//
//  GradeModels.swift
//  IOS_Student_Haven
//
//  Created on 12/6/2025.
//

import Foundation

// MARK: - Grade Entry
struct GradeEntry: Identifiable, Codable {
    let id: UUID
    var classId: String
    var className: String
    var assignmentName: String
    var grade: Double // Percentage (0-100)
    var weight: Double // Weight of assignment in final grade (0-1)
    var dateReceived: Date
    var category: GradeCategory
    
    init(id: UUID = UUID(),
         classId: String,
         className: String,
         assignmentName: String,
         grade: Double,
         weight: Double,
         dateReceived: Date = Date(),
         category: GradeCategory) {
        self.id = id
        self.classId = classId
        self.className = className
        self.assignmentName = assignmentName
        self.grade = grade
        self.weight = weight
        self.dateReceived = dateReceived
        self.category = category
    }
}

// MARK: - Grade Category
enum GradeCategory: String, Codable, CaseIterable {
    case homework = "Homework"
    case quiz = "Quiz"
    case exam = "Exam"
    case project = "Project"
    case participation = "Participation"
    case other = "Other"
}

// MARK: - Class Grade Summary
struct ClassGradeSummary: Identifiable {
    let id: UUID
    let classId: String
    let className: String
    var currentGrade: Double
    var letterGrade: String
    var creditHours: Double
    var gradeEntries: [GradeEntry]
    
    init(classId: String,
         className: String,
         currentGrade: Double,
         creditHours: Double,
         gradeEntries: [GradeEntry]) {
        self.id = UUID()
        self.classId = classId
        self.className = className
        self.currentGrade = currentGrade
        self.letterGrade = GradeCalculator.getLetterGrade(from: currentGrade)
        self.creditHours = creditHours
        self.gradeEntries = gradeEntries
    }
}

// MARK: - GPA Summary
struct GPASummary {
    var currentGPA: Double
    var totalCreditHours: Double
    var totalQualityPoints: Double
    var classSummaries: [ClassGradeSummary]
    var semesterGPA: Double
    
    init(currentGPA: Double = 0.0,
         totalCreditHours: Double = 0.0,
         totalQualityPoints: Double = 0.0,
         classSummaries: [ClassGradeSummary] = [],
         semesterGPA: Double = 0.0) {
        self.currentGPA = currentGPA
        self.totalCreditHours = totalCreditHours
        self.totalQualityPoints = totalQualityPoints
        self.classSummaries = classSummaries
        self.semesterGPA = semesterGPA
    }
}

// MARK: - Grade Goal
struct GradeGoal: Identifiable, Codable {
    let id: UUID
    var classId: String
    var className: String
    var targetGrade: Double
    var currentGrade: Double
    var deadline: Date?
    
    init(id: UUID = UUID(),
         classId: String,
         className: String,
         targetGrade: Double,
         currentGrade: Double,
         deadline: Date? = nil) {
        self.id = id
        self.classId = classId
        self.className = className
        self.targetGrade = targetGrade
        self.currentGrade = currentGrade
        self.deadline = deadline
    }
    
    var progress: Double {
        guard targetGrade > 0 else { return 0 }
        return min(currentGrade / targetGrade, 1.0)
    }
    
    var isAchieved: Bool {
        return currentGrade >= targetGrade
    }
}

// MARK: - Grade Calculator Helper
struct GradeCalculator {
    static func getLetterGrade(from percentage: Double) -> String {
        switch percentage {
        case 93...100: return "A"
        case 90..<93: return "A-"
        case 87..<90: return "B+"
        case 83..<87: return "B"
        case 80..<83: return "B-"
        case 77..<80: return "C+"
        case 73..<77: return "C"
        case 70..<73: return "C-"
        case 67..<70: return "D+"
        case 63..<67: return "D"
        case 60..<63: return "D-"
        default: return "F"
        }
    }
    
    static func getGradePoints(from letterGrade: String) -> Double {
        switch letterGrade {
        case "A": return 4.0
        case "A-": return 3.7
        case "B+": return 3.3
        case "B": return 3.0
        case "B-": return 2.7
        case "C+": return 2.3
        case "C": return 2.0
        case "C-": return 1.7
        case "D+": return 1.3
        case "D": return 1.0
        case "D-": return 0.7
        default: return 0.0
        }
    }
    
    static func calculateWeightedGrade(entries: [GradeEntry]) -> Double {
        let totalWeight = entries.reduce(0) { $0 + $1.weight }
        guard totalWeight > 0 else { return 0 }
        
        let weightedSum = entries.reduce(0.0) { $0 + ($1.grade * $1.weight) }
        return weightedSum / totalWeight
    }
}
