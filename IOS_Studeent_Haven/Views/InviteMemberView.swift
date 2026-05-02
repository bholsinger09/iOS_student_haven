//
//  InviteMemberView.swift
//  IOS_Student_Haven
//
//  Created on 1/2/2025.
//

import SwiftUI

struct InviteMemberView: View {
    let studyGroup: StudyGroup
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: InviteMemberViewModel
    
    init(studyGroup: StudyGroup, userRepository: UserRepositoryProtocol, studyGroupManager: StudyGroupManagementUseCase) {
        self.studyGroup = studyGroup
        _viewModel = StateObject(wrappedValue: InviteMemberViewModel(
            studyGroup: studyGroup,
            userRepository: userRepository,
            studyGroupManager: studyGroupManager
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Search fields
                VStack(alignment: .leading, spacing: 12) {
                    Text("Search for users to invite")
                        .font(.headline)
                    
                    TextField("First Name", text: $viewModel.searchFirstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.givenName)
                        .autocapitalization(.words)
                    
                    TextField("Email", text: $viewModel.searchEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    Button(action: {
                        Task {
                            await viewModel.searchUsers()
                        }
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Search")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(viewModel.isSearching)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Error message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // Search results
                if viewModel.isSearching {
                    ProgressView("Searching...")
                        .padding()
                } else if !viewModel.searchResults.isEmpty {
                    List(viewModel.searchResults) { user in
                        UserResultRow(
                            user: user,
                            onInvite: {
                                viewModel.inviteUser(user)
                            }
                        )
                    }
                } else if viewModel.hasSearched {
                    Text("No users found")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Invite Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Success", isPresented: $viewModel.showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(viewModel.successMessage)
            }
        }
    }
}

struct UserResultRow: View {
    let user: User
    let onInvite: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                Text(user.email)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: onInvite) {
                Text("Invite")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - View Model

@MainActor
class InviteMemberViewModel: ObservableObject {
    @Published var searchFirstName: String = ""
    @Published var searchEmail: String = ""
    @Published var searchResults: [User] = []
    @Published var isSearching = false
    @Published var errorMessage: String?
    @Published var hasSearched = false
    @Published var showSuccessAlert = false
    @Published var successMessage = ""
    
    private let studyGroup: StudyGroup
    private let searchUseCase: SearchUsersUseCase
    private let inviteUseCase: InviteUserToGroupUseCase
    private let currentUserId: String = "current-user-id" // TODO: Get from auth session
    
    init(studyGroup: StudyGroup, userRepository: UserRepositoryProtocol, studyGroupManager: StudyGroupManagementUseCase) {
        self.studyGroup = studyGroup
        self.searchUseCase = SearchUsersUseCase(userRepository: userRepository)
        self.inviteUseCase = InviteUserToGroupUseCase(studyGroupManager: studyGroupManager)
    }
    
    func searchUsers() async {
        isSearching = true
        errorMessage = nil
        hasSearched = true
        
        do {
            searchResults = try await searchUseCase.execute(
                firstName: searchFirstName,
                email: searchEmail
            )
        } catch {
            errorMessage = error.localizedDescription
            searchResults = []
        }
        
        isSearching = false
    }
    
    func inviteUser(_ user: User) {
        let result = inviteUseCase.execute(
            userId: user.id,
            groupId: studyGroup.id,
            invitingUserId: currentUserId
        )
        
        switch result {
        case .success:
            successMessage = "\(user.name) has been added to the group!"
            showSuccessAlert = true
            // Remove from search results
            searchResults.removeAll { $0.id == user.id }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}
