//
//  GPATrackerView.swift
//  IOS_Student_Haven
//
//  Created on 12/6/2025.
//

import SwiftUI

struct GPATrackerView: View {
    @StateObject private var viewModel = GPATrackerViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("View", selection: $selectedTab) {
                    Text("Overview").tag(0)
                    Text("Classes").tag(1)
                    Text("Goals").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                TabView(selection: $selectedTab) {
                    GPAOverviewView(viewModel: viewModel)
                        .tag(0)
                    
                    ClassGradesView(viewModel: viewModel)
                        .tag(1)
                    
                    GradeGoalsView(viewModel: viewModel)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("GPA Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            viewModel.showingAddGrade = true
                        } label: {
                            Label("Add Grade", systemImage: "plus.circle")
                        }
                        
                        Button {
                            viewModel.showingAddGoal = true
                        } label: {
                            Label("Add Goal", systemImage: "target")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddGrade) {
                AddGradeView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingAddGoal) {
                AddGoalView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - GPA Overview View
struct GPAOverviewView: View {
    @ObservedObject var viewModel: GPATrackerViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Current GPA Card
                VStack(spacing: 12) {
                    Text("Current GPA")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.formatGPA(viewModel.gpaSummary.currentGPA))
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("\(Int(viewModel.gpaSummary.totalCreditHours)) Credit Hours")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue.opacity(0.1))
                )
                .padding(.horizontal)
                
                // Class Summaries
                VStack(alignment: .leading, spacing: 12) {
                    Text("Classes")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    if viewModel.classSummaries.isEmpty {
                        EmptyStateView(
                            icon: "book.closed",
                            title: "No Grades Yet",
                            message: "Add grades to see your GPA"
                        )
                    } else {
                        ForEach(viewModel.classSummaries) { summary in
                            ClassSummaryCard(summary: summary, viewModel: viewModel)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Class Summary Card
struct ClassSummaryCard: View {
    let summary: ClassGradeSummary
    @ObservedObject var viewModel: GPATrackerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(summary.className)
                        .font(.headline)
                    
                    Text("\(summary.gradeEntries.count) assignments")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(summary.letterGrade)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.getGradeColor(summary.currentGrade))
                    
                    Text(viewModel.formatGrade(summary.currentGrade))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(viewModel.getGradeColor(summary.currentGrade))
                        .frame(width: geometry.size.width * (summary.currentGrade / 100), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

// MARK: - Class Grades View
struct ClassGradesView: View {
    @ObservedObject var viewModel: GPATrackerViewModel
    
    var body: some View {
        ScrollView {
            if viewModel.classSummaries.isEmpty {
                EmptyStateView(
                    icon: "square.and.pencil",
                    title: "No Grades",
                    message: "Start adding grades to track your performance"
                )
            } else {
                ForEach(viewModel.classSummaries) { summary in
                    NavigationLink(destination: ClassDetailGradesView(summary: summary, viewModel: viewModel)) {
                        ClassSummaryCard(summary: summary, viewModel: viewModel)
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Class Detail Grades View
struct ClassDetailGradesView: View {
    let summary: ClassGradeSummary
    @ObservedObject var viewModel: GPATrackerViewModel
    
    var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    Text(summary.letterGrade)
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(viewModel.getGradeColor(summary.currentGrade))
                    
                    Text(viewModel.formatGrade(summary.currentGrade))
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            
            Section("Grades") {
                ForEach(summary.gradeEntries) { entry in
                    GradeEntryRow(entry: entry, viewModel: viewModel)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.deleteGrade(id: summary.gradeEntries[index].id)
                    }
                }
            }
        }
        .navigationTitle(summary.className)
    }
}

// MARK: - Grade Entry Row
struct GradeEntryRow: View {
    let entry: GradeEntry
    @ObservedObject var viewModel: GPATrackerViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.assignmentName)
                    .font(.headline)
                
                HStack {
                    Text(entry.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                    
                    Text(entry.dateReceived, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(viewModel.formatGrade(entry.grade))
                .font(.headline)
                .foregroundColor(viewModel.getGradeColor(entry.grade))
        }
    }
}

// MARK: - Grade Goals View
struct GradeGoalsView: View {
    @ObservedObject var viewModel: GPATrackerViewModel
    
    var body: some View {
        ScrollView {
            if viewModel.gradeGoals.isEmpty {
                EmptyStateView(
                    icon: "target",
                    title: "No Goals Set",
                    message: "Set grade goals to stay motivated"
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.gradeGoals) { goal in
                        GradeGoalCard(goal: goal, viewModel: viewModel)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Grade Goal Card
struct GradeGoalCard: View {
    let goal: GradeGoal
    @ObservedObject var viewModel: GPATrackerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.className)
                        .font(.headline)
                    
                    if let deadline = goal.deadline {
                        Text("Due \(deadline, style: .date)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if goal.isAchieved {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            
            HStack {
                Text("Current: \(viewModel.formatGrade(goal.currentGrade))")
                    .font(.subheadline)
                
                Spacer()
                
                Text("Target: \(viewModel.formatGrade(goal.targetGrade))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.secondary)
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(goal.isAchieved ? Color.green : Color.blue)
                        .frame(width: geometry.size.width * goal.progress, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

// MARK: - Add Grade View
struct AddGradeView: View {
    @ObservedObject var viewModel: GPATrackerViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var classId = ""
    @State private var className = ""
    @State private var assignmentName = ""
    @State private var grade = ""
    @State private var weight = ""
    @State private var selectedCategory: GradeCategory = .homework
    
    var body: some View {
        NavigationView {
            Form {
                Section("Assignment Details") {
                    TextField("Class ID", text: $classId)
                    TextField("Class Name", text: $className)
                    TextField("Assignment Name", text: $assignmentName)
                }
                
                Section("Grade") {
                    TextField("Grade (%)", text: $grade)
                        .keyboardType(.decimalPad)
                    
                    TextField("Weight", text: $weight)
                        .keyboardType(.decimalPad)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(GradeCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Add Grade")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard let gradeValue = Double(grade),
                              let weightValue = Double(weight) else { return }
                        
                        viewModel.addGrade(
                            classId: classId,
                            className: className,
                            assignmentName: assignmentName,
                            grade: gradeValue,
                            weight: weightValue,
                            category: selectedCategory
                        )
                        dismiss()
                    }
                    .disabled(classId.isEmpty || className.isEmpty || assignmentName.isEmpty || grade.isEmpty || weight.isEmpty)
                }
            }
        }
    }
}

// MARK: - Add Goal View
struct AddGoalView: View {
    @ObservedObject var viewModel: GPATrackerViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var classId = ""
    @State private var className = ""
    @State private var targetGrade = ""
    @State private var currentGrade = ""
    @State private var hasDeadline = false
    @State private var deadline = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Class") {
                    TextField("Class ID", text: $classId)
                    TextField("Class Name", text: $className)
                }
                
                Section("Goal") {
                    TextField("Target Grade (%)", text: $targetGrade)
                        .keyboardType(.decimalPad)
                    
                    TextField("Current Grade (%)", text: $currentGrade)
                        .keyboardType(.decimalPad)
                }
                
                Section {
                    Toggle("Set Deadline", isOn: $hasDeadline)
                    
                    if hasDeadline {
                        DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Add Goal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard let targetValue = Double(targetGrade),
                              let currentValue = Double(currentGrade) else { return }
                        
                        viewModel.addGoal(
                            classId: classId,
                            className: className,
                            targetGrade: targetValue,
                            currentGrade: currentValue,
                            deadline: hasDeadline ? deadline : nil
                        )
                        dismiss()
                    }
                    .disabled(classId.isEmpty || className.isEmpty || targetGrade.isEmpty || currentGrade.isEmpty)
                }
            }
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    GPATrackerView()
}
