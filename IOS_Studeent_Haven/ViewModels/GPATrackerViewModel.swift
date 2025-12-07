//
//  GPATrackerViewModel.swift
//  IOS_Student_Haven
//
//  Created on 12/6/2025.
//

import Foundation
import SwiftUI

@MainActor
class GPATrackerViewModel: ObservableObject {
    @Published var gpaSummary: GPASummary = GPASummary()
    @Published var gradeEntries: [GradeEntry] = []
    @Published var gradeGoals: [GradeGoal] = []
    @Published var classSummaries: [ClassGradeSummary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAddGrade = false
    @Published var showingAddGoal = false
    
    private let gpaCalculator = GPACalculatorUseCase()
    private let gradeManager = GradeManagementUseCase()
    
    init() {
        loadData()
    }
    
    // MARK: - Load Data
    func loadData() {
        isLoading = true
        
        gradeEntries = gradeManager.getAllGrades()
        gradeGoals = gradeManager.getGoals()
        
        // Group grades by class and calculate summaries
        let groupedGrades = Dictionary(grouping: gradeEntries) { $0.classId }
        
        classSummaries = groupedGrades.map { classId, entries in
            let currentGrade = gpaCalculator.calculateClassGrade(entries: entries)
            let className = entries.first?.className ?? "Unknown"
            let creditHours = 3.0 // Default, should come from class data
            
            return ClassGradeSummary(
                classId: classId,
                className: className,
                currentGrade: currentGrade,
                creditHours: creditHours,
                gradeEntries: entries
            )
        }
        
        gpaSummary = gpaCalculator.calculateGPA(classSummaries: classSummaries)
        
        isLoading = false
    }
    
    // MARK: - Grade Management
    func addGrade(
        classId: String,
        className: String,
        assignmentName: String,
        grade: Double,
        weight: Double,
        category: GradeCategory
    ) {
        let newGrade = GradeEntry(
            classId: classId,
            className: className,
            assignmentName: assignmentName,
            grade: grade,
            weight: weight,
            category: category
        )
        
        gradeManager.addGrade(newGrade)
        loadData()
        showingAddGrade = false
    }
    
    func updateGrade(_ grade: GradeEntry) {
        gradeManager.updateGrade(grade)
        loadData()
    }
    
    func deleteGrade(id: UUID) {
        gradeManager.deleteGrade(id: id)
        loadData()
    }
    
    func getGrades(forClassId classId: String) -> [GradeEntry] {
        return gradeEntries.filter { $0.classId == classId }
    }
    
    // MARK: - Goal Management
    func addGoal(
        classId: String,
        className: String,
        targetGrade: Double,
        currentGrade: Double,
        deadline: Date? = nil
    ) {
        let newGoal = GradeGoal(
            classId: classId,
            className: className,
            targetGrade: targetGrade,
            currentGrade: currentGrade,
            deadline: deadline
        )
        
        gradeManager.addGoal(newGoal)
        loadData()
        showingAddGoal = false
    }
    
    func updateGoal(_ goal: GradeGoal) {
        gradeManager.updateGoal(goal)
        loadData()
    }
    
    func deleteGoal(id: UUID) {
        gradeManager.deleteGoal(id: id)
        loadData()
    }
    
    // MARK: - Calculations
    func calculateGradeNeeded(
        currentGrade: Double,
        currentWeight: Double,
        targetGrade: Double,
        finalWeight: Double
    ) -> Double? {
        return gpaCalculator.calculateGradeNeeded(
            currentGrade: currentGrade,
            currentWeight: currentWeight,
            targetGrade: targetGrade,
            finalWeight: finalWeight
        )
    }
    
    func calculateProjectedGPA(projectedGrades: [(grade: Double, creditHours: Double)]) -> Double {
        return gpaCalculator.calculateProjectedGPA(
            currentGPA: gpaSummary.currentGPA,
            currentCreditHours: gpaSummary.totalCreditHours,
            projectedGrades: projectedGrades
        )
    }
    
    // MARK: - Formatting Helpers
    func formatGPA(_ gpa: Double) -> String {
        return String(format: "%.2f", gpa)
    }
    
    func formatGrade(_ grade: Double) -> String {
        return String(format: "%.1f%%", grade)
    }
    
    func getGradeColor(_ grade: Double) -> Color {
        switch grade {
        case 90...100: return .green
        case 80..<90: return .blue
        case 70..<80: return .orange
        default: return .red
        }
    }
}
