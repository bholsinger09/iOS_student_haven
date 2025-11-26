//
//  IOS_Studeent_HavenApp.swift
//  IOS_Studeent_Haven
//
//  Created by Ben H on 11/26/25.
//

import SwiftUI
import Core
import Authentication
import ClassManagement
import Flashcards
import Notes

@main
struct IOS_Studeent_HavenApp: App {
    @StateObject private var appState = AppState.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}

// MARK: - AppState for managing app-wide state
@MainActor
class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    private init() {}
    
    // Repository access through DependencyContainer
    var authRepository: AuthRepositoryProtocol {
        DependencyContainer.shared.authRepository
    }
    
    var classRepository: ClassRepositoryProtocol {
        DependencyContainer.shared.classRepository
    }
    
    var flashcardRepository: FlashcardRepositoryProtocol {
        DependencyContainer.shared.flashcardRepository
    }
    
    var noteRepository: NoteRepositoryProtocol {
        DependencyContainer.shared.noteRepository
    }
    
    func login(user: User) {
        currentUser = user
        isAuthenticated = true
    }
    
    func logout() async {
        try? await authRepository.logout()
        currentUser = nil
        isAuthenticated = false
    }
}

// MARK: - DependencyContainer for managing repositories
class DependencyContainer {
    static let shared = DependencyContainer()
    
    var useMockRepositories = true
    
    private init() {}
    
    lazy var authRepository: AuthRepositoryProtocol = {
        MockAuthRepositoryImpl()
    }()
    
    lazy var classRepository: ClassRepositoryProtocol = {
        MockClassRepositoryImpl()
    }()
    
    lazy var flashcardRepository: FlashcardRepositoryProtocol = {
        MockFlashcardRepositoryImpl()
    }()
    
    lazy var noteRepository: NoteRepositoryProtocol = {
        MockNoteRepositoryImpl()
    }()
}
