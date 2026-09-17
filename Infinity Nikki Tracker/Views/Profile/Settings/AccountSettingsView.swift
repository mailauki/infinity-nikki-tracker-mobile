//
//  AccountSettingsView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/16/26.
//

import SwiftUI
import Supabase

struct AccountSettingsView: View {
    @State private var newEmail = ""
    @State private var isUpdatingEmail = false
    @State private var emailError: String?
    @State private var emailSuccess = false
    
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isUpdatingPassword = false
    @State private var passwordError: String?
    @State private var passwordSuccess = false
    
    @State private var showDeleteConfirmation = false
    @State private var isDeletingAccount = false
    @State private var deleteAccountError: String?
    
    var body: some View {
        List {
            Section("Change Email") {
                TextField("New Email", text: $newEmail)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                
                if let emailError {
                    Text(emailError)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
                
                if emailSuccess {
                    Text("Check your inbox to confirm the new email")
                        .foregroundStyle(.green)
                        .font(.caption)
                }
                
                Button {
                    updateEmail()
                } label: {
                    if isUpdatingEmail {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Update Email")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .fontWeight(.bold)
                .foregroundColor(Color.themePrimary)
                .disabled(isUpdatingEmail || newEmail.isEmpty)
            }
            .foregroundColor(Color.themeOnSurface)
            .listRowBackground(Color.themeSurfaceContainerLowest)
            
            Section("Change Password") {
                SecureField("New Password", text: $newPassword)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textContentType(.newPassword)
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textContentType(.newPassword)
                
                if let passwordError {
                    Text(passwordError)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
                
                if passwordSuccess {
                    Text("Password updated")
                        .foregroundStyle(.green)
                        .font(.caption)
                }
                
                Button {
                    updatePassword()
                } label: {
                    if isUpdatingPassword {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Update Password")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .fontWeight(.bold)
                .foregroundColor(Color.themePrimary)
                .disabled(isUpdatingPassword || newPassword.isEmpty || confirmPassword.isEmpty)
            }
            .foregroundColor(Color.themeOnSurface)
            .listRowBackground(Color.themeSurfaceContainerLowest)
            
            Section("Connected Accounts") {
                Text("TDB")
            }
            .foregroundColor(Color.themeOnSurface)
            .listRowBackground(Color.themeSurfaceContainerLowest)
            
            Section("Danger Zone") {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    if isDeletingAccount {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Delete Account")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .fontWeight(.bold)
                .foregroundColor(Color.themeOnError)
                .listRowBackground(Color.themeError)
                .disabled(isDeletingAccount)
            }
            .foregroundColor(Color.themeOnSurface)
        }
        .scrollContentBackground(.hidden)
        .background(Color.themeSurface)
        .confirmationDialog(
            "Delete Account?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Account", role: .destructive) {
                deleteAccount()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes your account and all of your saved progress. This can't be undone.")
        }
        .alert(
            "Couldn't Delete Account",
            isPresented: Binding(
                get: { deleteAccountError != nil },
                set: { if !$0 { deleteAccountError = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(deleteAccountError ?? "")
        }
    }
    
    // MARK: - Methods
    
    private func updateEmail() {
        Task {
            isUpdatingEmail = true
            emailSuccess = false
            emailError = nil
            defer { isUpdatingEmail = false }
            do {
                try await supabase.auth.update(user: UserAttributes(email: newEmail))
                emailSuccess = true
                newEmail = ""
            } catch {
                emailError = "Failed to update email: \(error.localizedDescription)"
            }
        }
    }
    
    private func updatePassword() {
        guard newPassword == confirmPassword else {
            passwordError = "Passwords don't match"
            return
        }
        Task {
            isUpdatingPassword = true
            passwordSuccess = false
            passwordError = nil
            defer { isUpdatingPassword = false }
            do {
                try await supabase.auth.update(user: UserAttributes(password: newPassword))
                passwordSuccess = true
                newPassword = ""
                confirmPassword = ""
            } catch {
                passwordError = "Failed to update password: \(error.localizedDescription)"
            }
        }
    }
    
    private func deleteAccount() {
        Task {
            isDeletingAccount = true
            deleteAccountError = nil
            defer { isDeletingAccount = false }
            do {
                try await supabase.rpc("delete_user").execute()
                try await supabase.auth.signOut()
            } catch {
                deleteAccountError = "Failed to delete account: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    AccountSettingsView()
}
