import Core
import SwiftUI

/// Home tab with college selection and dashboard
struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("selectedCollegeName") private var storedCollegeName: String = ""
    @State private var selectedCollege: String?
    @State private var showingCollegeSelector = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if let collegeName = selectedCollege {
                    CollegeDashboardView(collegeName: collegeName)
                        .id(collegeName)  // Force view recreation when college changes
                } else {
                    EmptyHomeView(onSelectCollege: { showingCollegeSelector = true })
                }
            }
            .navigationTitle("Home")
            .toolbar {
                if selectedCollege != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: { showingCollegeSelector = true }) {
                            VStack(spacing: 4) {
                                Image(systemName: "building.columns.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))

                                Text("Your College Choice")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .sheet(isPresented: $showingCollegeSelector) {
                CollegeSelectorView(selectedCollege: $selectedCollege)
            }
            .onAppear {
                // Load from @AppStorage first (from onboarding selection)
                if !storedCollegeName.isEmpty && selectedCollege == nil {
                    selectedCollege = storedCollegeName
                }
                // Fallback to user's collegeId if available
                else if let collegeId = appState.currentUser?.collegeId, selectedCollege == nil {
                    selectedCollege = collegeId
                }
            }
            .onChange(of: storedCollegeName) { newValue in
                if !newValue.isEmpty {
                    selectedCollege = newValue
                }
            }
        }
    }
}

/// Empty state for home view
struct EmptyHomeView: View {
    let onSelectCollege: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "building.columns.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))

            VStack(spacing: 8) {
                Text("Welcome to StudentStudyHaven!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Select your college to get started")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Button(action: onSelectCollege) {
                Text("Choose College")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(minWidth: 200)
                    .padding()
                    .background(Color(red: 0.73, green: 0.33, blue: 0.83))
                    .cornerRadius(12)
                    .shadow(
                        color: Color(red: 0.73, green: 0.33, blue: 0.83).opacity(0.3),
                        radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
        }
    }
}

/// College dashboard with fun facts
struct CollegeDashboardView: View {
    let collegeName: String
    @State private var funFacts: [CollegeFact] = []
    @State private var isLoadingFacts = false
    @State private var collegeStats: [CollegeStat] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // College Header
                VStack(alignment: .leading, spacing: 16) {
                    VStack(spacing: 8) {
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))

                        Text("My College Choice")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text(collegeName)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))

                        Text(collegeLocation(for: collegeName))
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))

                        Text("My College Choice")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                            .padding(.top, 8)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)

                // Fun Facts Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Fun Facts")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        if isLoadingFacts {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    .padding(.horizontal)

                    if funFacts.isEmpty && !isLoadingFacts {
                        Text("No fun facts available")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(funFacts, id: \.title) { fact in
                            FunFactCard(fact: fact)
                        }
                    }
                }

                // Quick Stats
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quick Stats")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12)
                    {
                        ForEach(collegeStats, id: \.label) { stat in
                            StatCard(stat: stat)
                        }
                    }
                }

                Spacer(minLength: 40)
            }
            .padding()
        }
        .task(id: collegeName) {
            async let facts: () = loadFunFacts()
            async let stats: () = loadCollegeStats()
            await facts
            await stats
        }
        .onChange(of: collegeName) { newValue in
            // Clear facts and stats immediately when college changes
            funFacts = []
            collegeStats = []
            isLoadingFacts = true
        }
    }

    private func loadFunFacts() async {
        isLoadingFacts = true

        do {
            // Try to get from College model first
            if let college = College.sampleColleges.first(where: { $0.name == collegeName }),
                !college.funFacts.isEmpty
            {
                funFacts = college.funFacts.map { funFact in
                    CollegeFact(
                        icon: funFact.icon, title: funFact.title, description: funFact.description)
                }
            } else {
                // Fallback to AI-generated facts
                let aiFacts = try await AIFunFactService.shared.getFunFacts(for: collegeName)
                funFacts = aiFacts.map { funFact in
                    CollegeFact(
                        icon: funFact.icon, title: funFact.title, description: funFact.description)
                }
            }
        } catch {
            // Use fallback facts
            funFacts = [
                CollegeFact(
                    icon: "graduationcap.fill", title: "Academic Excellence",
                    description: "A renowned institution with a rich history"),
                CollegeFact(
                    icon: "person.3.fill", title: "Diverse Community",
                    description: "Students from all backgrounds and countries"),
                CollegeFact(
                    icon: "building.2.fill", title: "Modern Campus",
                    description: "State-of-the-art facilities and resources"),
            ]
        }

        isLoadingFacts = false
    }

    private func collegeLocation(for name: String) -> String {
        // Get location from College model
        if let college = College.sampleColleges.first(where: { $0.name == name }) {
            return college.location
        }
        return "United States"
    }

    private func loadCollegeStats() async {
        do {
            let stats = try await AICollegeStatsService.shared.getStats(for: collegeName)
            collegeStats = [
                CollegeStat(icon: "person.3.fill", label: "Students", value: stats.students),
                CollegeStat(
                    icon: "chart.line.uptrend.xyaxis", label: "Acceptance", value: stats.acceptance),
            ]
        } catch {
            // Fallback stats
            collegeStats = [
                CollegeStat(icon: "person.3.fill", label: "Students", value: "15,000"),
                CollegeStat(icon: "chart.line.uptrend.xyaxis", label: "Acceptance", value: "60%"),
            ]
        }
    }
}

/// Fun fact card
struct FunFactCard: View {
    let fact: CollegeFact

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.73, green: 0.33, blue: 0.83).opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: fact.icon)
                    .font(.title3)
                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(fact.title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(fact.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

/// Stat card
struct StatCard: View {
    let stat: CollegeStat

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: stat.icon)
                .font(.title2)
                .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))

            Text(stat.value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(stat.label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal, 6)
    }
}

/// College selector sheet with step-by-step selection
struct CollegeSelectorView: View {
    @Binding var selectedCollege: String?
    @AppStorage("selectedCollegeName") private var storedCollegeName: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var selectedState: String = ""
    @State private var selectedUniversity: String = ""

    let collegesByState: [String: [String]] = [
        "Alabama": [
            "University of Alabama", "Auburn University", "University of Alabama at Birmingham",
        ],
        "Alaska": ["University of Alaska Fairbanks", "University of Alaska Anchorage"],
        "Arizona": [
            "Arizona State University", "University of Arizona", "Northern Arizona University",
        ],
        "Arkansas": ["University of Arkansas", "Arkansas State University"],
        "California": [
            "Stanford University", "University of California, Berkeley", "UCLA", "USC", "Caltech",
            "UC San Diego", "UC Davis", "UC Irvine", "UC Santa Barbara", "Pepperdine University",
        ],
        "Colorado": [
            "University of Colorado Boulder", "Colorado State University", "University of Denver",
        ],
        "Connecticut": [
            "Yale University", "University of Connecticut", "Wesleyan University",
            "Trinity College",
        ],
        "Delaware": ["University of Delaware", "Delaware State University"],
        "Florida": [
            "University of Florida", "Florida State University", "University of Miami",
            "University of Central Florida", "University of South Florida",
        ],
        "Georgia": [
            "Georgia Institute of Technology", "University of Georgia", "Emory University",
            "Georgia State University",
        ],
        "Hawaii": ["University of Hawaii at Manoa", "Hawaii Pacific University"],
        "Idaho": ["Boise State University", "University of Idaho", "Idaho State University"],
        "Illinois": [
            "University of Chicago", "Northwestern University",
            "University of Illinois Urbana-Champaign", "University of Illinois Chicago",
            "DePaul University",
        ],
        "Indiana": [
            "Purdue University", "Indiana University Bloomington", "University of Notre Dame",
            "Ball State University",
        ],
        "Iowa": ["University of Iowa", "Iowa State University", "Drake University"],
        "Kansas": ["University of Kansas", "Kansas State University", "Wichita State University"],
        "Kentucky": [
            "University of Kentucky", "University of Louisville", "Western Kentucky University",
        ],
        "Louisiana": [
            "Louisiana State University", "Tulane University", "University of New Orleans",
        ],
        "Maine": ["University of Maine", "Bowdoin College", "Colby College"],
        "Maryland": [
            "Johns Hopkins University", "University of Maryland College Park",
            "University of Maryland Baltimore County",
        ],
        "Massachusetts": [
            "Harvard University", "MIT", "Boston University", "Tufts University",
            "Northeastern University", "Boston College", "UMass Amherst", "Williams College",
        ],
        "Michigan": [
            "University of Michigan", "Michigan State University", "Wayne State University",
            "Western Michigan University",
        ],
        "Minnesota": [
            "University of Minnesota Twin Cities", "Carleton College", "Macalester College",
        ],
        "Mississippi": [
            "University of Mississippi", "Mississippi State University",
            "University of Southern Mississippi",
        ],
        "Missouri": [
            "Washington University in St. Louis", "University of Missouri",
            "Saint Louis University", "Missouri State University",
        ],
        "Montana": ["University of Montana", "Montana State University"],
        "Nebraska": ["University of Nebraska Lincoln", "Creighton University"],
        "Nevada": ["University of Nevada Las Vegas", "University of Nevada Reno"],
        "New Hampshire": ["Dartmouth College", "University of New Hampshire"],
        "New Jersey": [
            "Princeton University", "Rutgers University", "Stevens Institute of Technology",
            "Seton Hall University",
        ],
        "New Mexico": ["University of New Mexico", "New Mexico State University"],
        "New York": [
            "Columbia University", "Cornell University", "NYU", "University of Rochester",
            "Syracuse University", "RPI", "Fordham University", "Stony Brook University",
        ],
        "North Carolina": [
            "Duke University", "University of North Carolina Chapel Hill",
            "North Carolina State University", "Wake Forest University",
        ],
        "North Dakota": ["University of North Dakota", "North Dakota State University"],
        "Ohio": [
            "Ohio State University", "Case Western Reserve University", "University of Cincinnati",
            "Ohio University",
        ],
        "Oklahoma": ["University of Oklahoma", "Oklahoma State University"],
        "Oregon": ["University of Oregon", "Oregon State University", "Portland State University"],
        "Pennsylvania": [
            "University of Pennsylvania", "Carnegie Mellon University", "Penn State University",
            "Drexel University", "Temple University", "University of Pittsburgh",
        ],
        "Rhode Island": ["Brown University", "University of Rhode Island", "Providence College"],
        "South Carolina": [
            "University of South Carolina", "Clemson University", "College of Charleston",
        ],
        "South Dakota": ["University of South Dakota", "South Dakota State University"],
        "Tennessee": [
            "Vanderbilt University", "University of Tennessee Knoxville", "University of Memphis",
        ],
        "Texas": [
            "University of Texas at Austin", "Rice University", "Texas A&M University",
            "University of Houston", "Texas Tech University", "Southern Methodist University",
        ],
        "Utah": ["University of Utah", "Brigham Young University", "Utah State University"],
        "Vermont": ["University of Vermont", "Middlebury College"],
        "Virginia": [
            "University of Virginia", "Virginia Tech", "William & Mary", "George Mason University",
        ],
        "Washington": [
            "University of Washington", "Washington State University", "Seattle University",
        ],
        "West Virginia": ["West Virginia University", "Marshall University"],
        "Wisconsin": [
            "University of Wisconsin Madison", "Marquette University",
            "University of Wisconsin Milwaukee",
        ],
        "Wyoming": ["University of Wyoming"],
    ]

    var sortedStates: [String] {
        collegesByState.keys.sorted()
    }

    var universitiesInSelectedState: [String] {
        guard !selectedState.isEmpty else { return [] }
        return collegesByState[selectedState] ?? []
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))

                        Text("Choose Your College")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Select your state and university")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)

                    Spacer()

                    // Step 1: State Dropdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Step 1: Select State")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        Menu {
                            ForEach(sortedStates, id: \.self) { state in
                                Button(state) {
                                    selectedState = state
                                    selectedUniversity = ""  // Reset university when state changes
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedState.isEmpty ? "Choose a State" : selectedState)
                                    .foregroundColor(selectedState.isEmpty ? .gray : .white)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }

                    // Step 2: University Dropdown (only show if state is selected)
                    if !selectedState.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Step 2: Select University")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)

                            Menu {
                                ForEach(universitiesInSelectedState, id: \.self) { university in
                                    Button(university) {
                                        selectedUniversity = university
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(
                                        selectedUniversity.isEmpty
                                            ? "Choose a University" : selectedUniversity
                                    )
                                    .foregroundColor(selectedUniversity.isEmpty ? .gray : .white)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Spacer()

                    // Action Buttons
                    HStack(spacing: 16) {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)

                        Button(action: {
                            if !selectedUniversity.isEmpty {
                                selectedCollege = selectedUniversity
                                storedCollegeName = selectedUniversity
                                dismiss()
                            }
                        }) {
                            Text("Save")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    selectedUniversity.isEmpty
                                        ? Color.gray
                                        : Color(red: 0.73, green: 0.33, blue: 0.83)
                                )
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        .disabled(selectedUniversity.isEmpty)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Select College")
        }
    }
}

// MARK: - Models

struct CollegeFact {
    let icon: String
    let title: String
    let description: String
}

struct CollegeStat {
    let icon: String
    let label: String
    let value: String
}
