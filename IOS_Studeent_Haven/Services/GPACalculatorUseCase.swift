//
//  GPACalculatorUseCase.swift
//  IOS_Student_Haven
//
//  Created on 12/6/2025.
//

import Foundation

// MARK: - GPA Calculator Use Case
class GPACalculatorUseCase {
    
    // MARK: - Calculate Current GPA
    func calculateGPA(classSummaries: [ClassGradeSummary]) -> GPASummary {
        var totalQualityPoints = 0.0
        var totalCreditHours = 0.0
        
        for summary in classSummaries {
            let gradePoints = GradeCalculator.getGradePoints(from: summary.letterGrade)
            let qualityPoints = gradePoints * summary.creditHours
            
            totalQualityPoints += qualityPoints
            totalCreditHours += summary.creditHours
        }
        
        let gpa = totalCreditHours > 0 ? totalQualityPoints / totalCreditHours : 0.0
        
        return GPASummary(
            currentGPA: gpa,
            totalCreditHours: totalCreditHours,
            totalQualityPoints: totalQualityPoints,
            classSummaries: classSummaries,
            semesterGPA: gpa
        )
    }
    
    // MARK: - Calculate Class Grade
    func calculateClassGrade(entries: [GradeEntry]) -> Double {
        return GradeCalculator.calculateWeightedGrade(entries: entries)
    }
    
    // MARK: - Calculate Projected GPA
    func calculateProjectedGPA(
        currentGPA: Double,
        currentCreditHours: Double,
        projectedGrades: [(grade: Double, creditHours: Double)]
    ) -> Double {
        var totalQualityPoints = currentGPA * currentCreditHours
        var totalCreditHours = currentCreditHours
        
        for projected in projectedGrades {
            let letterGrade = GradeCalculator.getLetterGrade(from: projected.grade)
            let gradePoints = GradeCalculator.getGradePoints(from: letterGrade)
            totalQualityPoints += gradePoints * projected.creditHours
            totalCreditHours += projected.creditHours
        }
        
        return totalCreditHours > 0 ? totalQualityPoints / totalCreditHours : 0.0
    }
    
    // MARK: - Calculate Grade Needed
    func calculateGradeNeeded(
        currentGrade: Double,
        currentWeight: Double,
        targetGrade: Double,
        finalWeight: Double
    ) -> Double? {
        // Formula: targetGrade = (currentGrade * currentWeight) + (neededGrade * finalWeight)
        // Solving for neededGrade:
        let neededGrade = (targetGrade - (currentGrade * currentWeight)) / finalWeight
        
        // Return nil if impossible (needs > 100%)
        guard neededGrade <= 100 else { return nil }
        
        return max(0, neededGrade)
    }
    
    // MARK: - Calculate Semester GPA
    func calculateSemesterGPA(grades: [ClassGradeSummary]) -> Double {
        return calculateGPA(classSummaries: grades).semesterGPA
    }
    
    // MARK: - Calculate Cumulative GPA with new semester
    func calculateCumulativeGPA(
        previousGPA: Double,
        previousCreditHours: Double,
        newSemesterGrades: [ClassGradeSummary]
    ) -> Double {
        let newSemesterSummary = calculateGPA(classSummaries: newSemesterGrades)
        
        let previousQualityPoints = previousGPA * previousCreditHours
        let totalQualityPoints = previousQualityPoints + newSemesterSummary.totalQualityPoints
        let totalCreditHours = previousCreditHours + newSemesterSummary.totalCreditHours
        
        return totalCreditHours > 0 ? totalQualityPoints / totalCreditHours : 0.0
    }
}

// MARK: - Grade Management Use Case
class GradeManagementUseCase {
    private var grades: [GradeEntry] = []
    private var goals: [GradeGoal] = []
    
    // MARK: - Grade Entry Management
    func addGrade(_ grade: GradeEntry) {
        grades.append(grade)
        saveGrades()
    }
    
    func updateGrade(_ grade: GradeEntry) {
        if let index = grades.firstIndex(where: { $0.id == grade.id }) {
            grades[index] = grade
            saveGrades()
        }
    }
    
    func deleteGrade(id: UUID) {
        grades.removeAll { $0.id == id }
        saveGrades()
    }
    
    func getGrades(forClassId classId: String) -> [GradeEntry] {
        return grades.filter { $0.classId == classId }
    }
    
    func getAllGrades() -> [GradeEntry] {
        return grades
    }
    
    // MARK: - Goal Management
    func addGoal(_ goal: GradeGoal) {
        goals.append(goal)
        saveGoals()
    }
    
    func updateGoal(_ goal: GradeGoal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveGoals()
        }
    }
    
    func deleteGoal(id: UUID) {
        goals.removeAll { $0.id == id }
        saveGoals()
    }
    
    func getGoals() -> [GradeGoal] {
        return goals
    }
    
    func getGoal(forClassId classId: String) -> GradeGoal? {
        return goals.first { $0.classId == classId }
    }
    
    // MARK: - Check Goals
    func checkGoalProgress(classId: String, currentGrade: Double) -> GradeGoal? {
        guard let goalIndex = goals.firstIndex(where: { $0.classId == classId }) else {
            return nil
        }
        
        goals[goalIndex].currentGrade = currentGrade
        saveGoals()
        
        return goals[goalIndex]
    }
    
    // MARK: - Persistence
    private func saveGrades() {
        if let encoded = try? JSONEncoder().encode(grades) {
            UserDefaults.standard.set(encoded, forKey: "savedGrades")
        }
    }
    
    private func loadGrades() {
        if let data = UserDefaults.standard.data(forKey: "savedGrades"),
           let decoded = try? JSONDecoder().decode([GradeEntry].self, from: data) {
            grades = decoded
        }
    }
    
    private func saveGoals() {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: "savedGoals")
        }
    }
    
    private func loadGoals() {
        if let data = UserDefaults.standard.data(forKey: "savedGoals"),
           let decoded = try? JSONDecoder().decode([GradeGoal].self, from: data) {
            goals = decoded
        }
    }
    
    init() {
        loadGrades()
        loadGoals()
    }
}
