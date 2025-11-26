import SwiftUI

/// Onboarding page model
struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let color: Color
}

/// Onboarding data
let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
        icon: "graduationcap.fill",
        title: "Welcome to StudentStudyHaven!",
        description:
            "Your all-in-one study companion. Organize classes, take notes, create flashcards, and track your academic progress all in one place.",
        color: Color(red: 0.73, green: 0.33, blue: 0.83)
    ),
    OnboardingPage(
        icon: "book.fill",
        title: "Organize Your Classes",
        description:
            "Keep track of all your classes, schedules, and course materials. Add class times, locations, professors, and important deadlines in one organized view.",
        color: Color.blue
    ),
    OnboardingPage(
        icon: "note.text",
        title: "Take Smart Notes",
        description: "Create rich notes with formatting, tags, and links. Connect related notes together to build your personal knowledge base and never lose important information.",
        color: Color.green
    ),
    OnboardingPage(
        icon: "rectangle.stack.fill",
        title: "Study with Flashcards",
        description:
            "Generate flashcards from your notes automatically. Practice with spaced repetition to retain information longer and ace your exams.",
        color: Color.orange
    ),
    OnboardingPage(
        icon: "building.columns.fill",
        title: "Your College Dashboard",
        description:
            "Choose your college to see fun facts, student statistics, and acceptance rates. Stay connected to your campus community.",
        color: Color(red: 0.73, green: 0.33, blue: 0.83)
    ),
]

/// Onboarding view
public struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .foregroundColor(.gray)
                    .padding()
                }

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(onboardingPages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }

                    // College selection page
                    CollegeSelectionView()
                        .tag(onboardingPages.count)
                }

                // Custom page indicator
                HStack(spacing: 8) {
                    ForEach(0...onboardingPages.count, id: \.self) { index in
                        Circle()
                            .fill(
                                currentPage == index
                                    ? Color(red: 0.73, green: 0.33, blue: 0.83)
                                    : Color.gray.opacity(0.3)
                            )
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.bottom, 20)

                // Navigation buttons
                HStack(spacing: 20) {
                    if currentPage > 0 {
                        Button {
                            withAnimation {
                                currentPage -= 1
                            }
                        } label: {
                            Text("Back")
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }

                    Button {
                        if currentPage < onboardingPages.count {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    } label: {
                        Text(currentPage < onboardingPages.count ? "Next" : "Get Started")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.73, green: 0.33, blue: 0.83))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func completeOnboarding() {
        hasCompletedOnboarding = true
        dismiss()
    }
}

/// Individual onboarding page view
struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 140, height: 140)

                Image(systemName: page.icon)
                    .font(.system(size: 60))
                    .foregroundColor(page.color)
            }

            // Title
            Text(page.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Description
            Text(page.description)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }
}
