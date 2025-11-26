import Core
import SwiftUI

/// College selection view for onboarding
public struct CollegeSelectionView: View {
    @AppStorage("selectedCollegeId") private var selectedCollegeId: String = ""
    @AppStorage("selectedCollegeName") private var selectedCollegeName: String = ""
    @State private var selectedCollege: College?
    @State private var showingCollegeList = false

    public init() {}

    public var body: some View {
        VStack(spacing: 30) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(red: 0.73, green: 0.33, blue: 0.83).opacity(0.2))
                    .frame(width: 140, height: 140)

                Image(systemName: "building.columns.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
            }

            // Title
            Text("Choose Your College")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Selected college or prompt
            if let college = selectedCollege {
                collegeCard(college)
            } else {
                // Description
                Text("Select your university and get personalized fun facts and statistics.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Button {
                    showingCollegeList = true
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Select College")
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.73, green: 0.33, blue: 0.83))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }
        }
        .sheet(isPresented: $showingCollegeList) {
            CollegeListSheet(selectedCollege: $selectedCollege)
        }
        .onAppear {
            if !selectedCollegeId.isEmpty {
                selectedCollege = College.sampleColleges.first { $0.id == selectedCollegeId }
            }
        }
        .onChange(of: selectedCollege) { newValue in
            if let college = newValue {
                selectedCollegeId = college.id
                selectedCollegeName = college.name
            }
        }
    }

    private func collegeCard(_ college: College) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // College name and location
            VStack(alignment: .leading, spacing: 4) {
                Text(college.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))

                Text(college.location)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                showingCollegeList = true
            } label: {
                Text("My College Choice")
                    .font(.caption)
                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.73, green: 0.33, blue: 0.83).opacity(0.2))
                    .cornerRadius(8)
            }

            // Fun Facts
            if !college.funFacts.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fun Facts")
                        .font(.headline)
                        .foregroundColor(.white)

                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(college.funFacts.prefix(3)) { fact in
                                funFactRow(fact)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal, 24)
    }

    private func funFactRow(_ fact: FunFact) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.73, green: 0.33, blue: 0.83).opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: fact.icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(fact.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text(fact.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.03))
        .cornerRadius(12)
    }
}

/// Sheet for selecting a college from the list
struct CollegeListSheet: View {
    @Binding var selectedCollege: College?
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredColleges: [College] {
        if searchText.isEmpty {
            return College.sampleColleges
        } else {
            return College.sampleColleges.filter { college in
                college.name.localizedCaseInsensitiveContains(searchText)
                    || college.location.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(filteredColleges) { college in
                            Button {
                                selectedCollege = college
                                dismiss()
                            } label: {
                                collegeListItem(college)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Select Your College")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                }
            }
            .searchable(text: $searchText, prompt: "Search colleges...")
        }
        .preferredColorScheme(.dark)
    }

    private func collegeListItem(_ college: College) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.73, green: 0.33, blue: 0.83).opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: "building.columns.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(college.name)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(college.location)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if !college.funFacts.isEmpty {
                    Text("\(college.funFacts.count) fun facts")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}
