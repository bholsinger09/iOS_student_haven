import Authentication
import ClassManagement
import Core
import Flashcards
import Notes
import SwiftUI

/// Root view that handles authentication state
struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        if appState.isAuthenticated {
            MainTabView()
        } else {
            LoginView(
                viewModel: LoginViewModel(
                    loginUseCase: LoginUseCase(
                        authRepository: appState.authRepository
                    )
                )
            )
            .onReceive(NotificationCenter.default.publisher(for: .userDidLogin)) { notification in
                if let user = notification.object as? User {
                    appState.login(user: user)
                }
            }
        }
    }
}

/// Main tab view after authentication
struct MainTabView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            HomeTab()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ClassesTab()
                .tabItem {
                    Label("Classes", systemImage: "book.fill")
                }

            NotesTab()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
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
    }
}

/// Home tab with college selection and stats
struct HomeTab: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Welcome to Study Haven!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    Text("Select your college to get started")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Quick stats or info can go here
                    VStack(spacing: 12) {
                        StatCard(title: "Classes", value: "0", icon: "book.fill")
                        StatCard(title: "Notes", value: "0", icon: "note.text")
                        StatCard(title: "Flashcards", value: "0", icon: "rectangle.stack.fill")
                    }
                    .padding()
                }
            }
            .navigationTitle("Home")
        }
    }
}


/// Classes tab - simplified for iOS
struct ClassesTab: View {
    @EnvironmentObject var appState: AppState
    @State private var classes: [Class] = []
    @State private var isLoading = false
    @State private var showingAddClass = false

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if classes.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Classes Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Tap + to add your first class")
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(classes) { classItem in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(classItem.name)
                                    .font(.headline)
                                Text(classItem.courseCode)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteClasses)
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
            .task {
                await loadClasses()
            }
        }
    }

    private func loadClasses() async {
        guard let userId = appState.currentUser?.id else { return }
        isLoading = true
        do {
            let useCase = GetClassesUseCase(classRepository: appState.classRepository)
            classes = try await useCase.execute(userId: userId)
        } catch {
            print("Error loading classes: \(error)")
        }
        isLoading = false
    }

    private func deleteClasses(at offsets: IndexSet) {
        let classesToDelete = offsets.map { classes[$0] }
        Task {
            let useCase = DeleteClassUseCase(classRepository: appState.classRepository)
            for classItem in classesToDelete {
                do {
                    try await useCase.execute(classId: classItem.id)
                } catch {
                    print("Error deleting class: \(error)")
                }
            }
            await MainActor.run {
                classes.remove(atOffsets: offsets)
            }
        }
    }
}

/// Notes tab - simplified for iOS
struct NotesTab: View {
    @EnvironmentObject var appState: AppState
    @State private var notes: [Note] = []

    var body: some View {
        NavigationStack {
            Group {
                if notes.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "note.text")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Notes Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Create classes first, then add notes")
                            .foregroundColor(.secondary)
                    }
                } else {
                    List(notes) { note in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.title)
                                .font(.headline)
                            Text(note.content.prefix(100))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Notes")
        }
    }
}

/// Flashcards tab - simplified for iOS
struct FlashcardsTab: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "rectangle.stack.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                Text("Flashcards Coming Soon")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Create flashcards from your notes")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Flashcards")
        }
    }
}


/// Profile tab
struct ProfileTab: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                if let user = appState.currentUser {
                    Section("Account") {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(user.name)
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section {
                    Button(
                        role: .destructive,
                        action: {
                            Task {
                                await appState.logout()
                            }
                        }
                    ) {
                        HStack {
                            Spacer()
                            Text("Logout")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}
