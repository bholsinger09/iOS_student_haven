import Authentication
import ClassManagement
import Core
import Flashcards
import Notes
import SwiftUI

/// Root view that handles authentication state
struct RootView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false

    var body: some View {
        if appState.isAuthenticated {
            MainTabView()
                .preferredColorScheme(.dark)
                .sheet(isPresented: $showOnboarding) {
                    OnboardingView()
                }
                .onAppear {
                    if !hasCompletedOnboarding {
                        showOnboarding = true
                    }
                }
        } else {
            AuthenticationCoordinator()
                .preferredColorScheme(.dark)
        }
    }
}

/// Authentication coordinator
struct AuthenticationCoordinator: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        LoginView(
            viewModel: LoginViewModel(
                loginUseCase: LoginUseCase(
                    authRepository: appState.authRepository
                )
            ),
            authRepository: appState.authRepository
        )
        .onReceive(NotificationCenter.default.publisher(for: .userDidLogin)) { notification in
            if let user = notification.object as? User {
                appState.login(user: user)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UserDidRegister"))) { notification in
            if let user = notification.object as? User {
                appState.login(user: user)
            }
        }
    }
}

/// Main tab view after authentication
struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    init() {
        // Configure More screen appearance immediately
        UITabBar.appearance().backgroundColor = .systemBackground
        
        // Use introspection to access and style the More navigation controller
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                for window in windowScene.windows {
                    if let tabBarController = window.rootViewController as? UITabBarController {
                        tabBarController.moreNavigationController.overrideUserInterfaceStyle = .dark
                    }
                }
            }
        }
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            ClassesTab()
                .tabItem {
                    Label("Classes", systemImage: "book.fill")
                }
            
            GPATrackerView()
                .tabItem {
                    Label("GPA", systemImage: "chart.bar.fill")
                }
            
            StudyGroupFinderView()
                .tabItem {
                    Label("Study Groups", systemImage: "person.3.fill")
                }
            
            MyAvatarView()
                .tabItem {
                    Label("Avatar", systemImage: "person.crop.circle.fill")
                }

            NotesTab()
                .tabItem {
                    Label("Notes", systemImage: "pencil.and.list.clipboard")
                }

            FlashcardsTab()
                .tabItem {
                    Label("Flashcards", systemImage: "rectangle.stack.fill")
                }

            ProfileTab()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .onAppear {
            // Set tab bar appearance for dark mode support
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor.systemBackground
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            
            // Force dark style for More navigation controller
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let tabBarController = windowScene.windows.first?.rootViewController as? UITabBarController {
                    let moreNavigationController = tabBarController.moreNavigationController
                    moreNavigationController.overrideUserInterfaceStyle = .dark
                    moreNavigationController.navigationBar.overrideUserInterfaceStyle = .dark
                }
            }
        }
    }
}

/// Classes tab
struct ClassesTab: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ClassListView(
                userId: UUID(uuidString: appState.currentUser?.id ?? UUID().uuidString) ?? UUID()
            )
        }
    }
}

/// Class list view
struct ClassListView: View {
    let userId: UUID
    @EnvironmentObject var appState: AppState
    @State private var classes: [Class] = []
    @State private var isLoading = false
    @State private var showingAddClass = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if classes.isEmpty {
                EmptyClassesView {
                    showingAddClass = true
                }
            } else {
                List {
                    ForEach(classes) { classItem in
                        NavigationLink(destination: ClassDetailView(classItem: classItem)) {
                            ClassRow(classItem: classItem)
                        }
                    }
                    .onDelete { indexSet in
                        deleteClasses(at: indexSet)
                    }
                }
            }
        }
        .navigationTitle("My Classes")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddClass = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddClass) {
            AddClassView(
                viewModel: ClassFormViewModel(
                    createClassUseCase: IOS_Student_Haven.CreateClassUseCase(
                        repository: appState.classRepository),
                    updateClassUseCase: IOS_Student_Haven.UpdateClassUseCase(
                        repository: appState.classRepository),
                    userId: userId.uuidString
                ))
        }
        .task {
            await loadClasses()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ClassDidSave"))) { _ in
            Task {
                await loadClasses()
            }
        }
    }

    private func loadClasses() async {
        isLoading = true
        do {
            let useCase = GetClassesUseCase(classRepository: appState.classRepository)
            classes = try await useCase.execute(userId: userId.uuidString)
        } catch {
            print("Error loading classes: \(error)")
        }
        isLoading = false
    }

    private func deleteClasses(at offsets: IndexSet) {
        Task {
            let useCase = DeleteClassUseCase(classRepository: appState.classRepository)
            for index in offsets {
                do {
                    try await useCase.execute(classId: classes[index].id)
                    classes.remove(at: index)
                } catch {
                    print("Error deleting class: \(error)")
                }
            }
        }
    }
}

/// Empty state for classes
struct EmptyClassesView: View {
    let onAddClass: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("No Classes Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Add your first class to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button(action: onAddClass) {
                Label("Add Class", systemImage: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ClassRow: View {
    let classItem: Class

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(classItem.name)
                .font(.headline)
            Text(classItem.courseCode)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

/// Notes tab
struct NotesTab: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            if let userId = appState.currentUser?.id {
                NotesListView(
                    viewModel: NotesListViewModel(
                        getNotesUseCase: GetNotesUseCase(noteRepository: appState.noteRepository),
                        deleteNoteUseCase: DeleteNoteUseCase(
                            noteRepository: appState.noteRepository),
                        classId: appState.currentUser?.collegeId ?? ""
                    ),
                    classId: appState.currentUser?.collegeId ?? "",
                    userId: userId,
                    createNoteUseCase: CreateNoteUseCase(noteRepository: appState.noteRepository),
                    updateNoteUseCase: UpdateNoteUseCase(noteRepository: appState.noteRepository)
                )
            } else {
                ZStack {
                    Color.black.ignoresSafeArea()
                    Text("Please log in to view notes")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

/// Note row view
struct NoteRowView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title)
                .font(.headline)

            Text(note.content.prefix(100))
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            if !note.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(note.tags.prefix(3), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

/// Flashcards tab
struct FlashcardsTab: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            if let userId = appState.currentUser?.id {
                FlashcardListView(
                    viewModel: FlashcardListViewModel(
                        getFlashcardsUseCase: GetFlashcardsUseCase(
                            flashcardRepository: appState.flashcardRepository),
                        updateFlashcardUseCase: UpdateFlashcardUseCase(
                            flashcardRepository: appState.flashcardRepository),
                        createFlashcardUseCase: CreateFlashcardUseCase(
                            flashcardRepository: appState.flashcardRepository),
                        classId: appState.currentUser?.collegeId ?? "",
                        userId: userId
                    )
                )
            } else {
                ZStack {
                    Color.black.ignoresSafeArea()
                    Text("Please log in to view flashcards")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

/// Flashcard row view
struct FlashcardRowView: View {
    let flashcard: Flashcard

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(flashcard.front)
                .font(.headline)
            Text(flashcard.back)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}

/// Empty state for flashcards
struct EmptyFlashcardsView: View {
    let onCreateFlashcard: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "rectangle.stack.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.green)

                Text("No Flashcards Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text("Create notes and generate flashcards to start studying")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Button(action: onCreateFlashcard) {
                    Text("Create Flashcard")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(minWidth: 180, minHeight: 44)
                        .background(Color(red: 0.73, green: 0.33, blue: 0.83))
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .padding(.top, 10)
            }
        }
    }
}

/// Profile tab
struct ProfileTab: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ProfileView(viewModel: ProfileViewModel(appState: appState))
    }
}
