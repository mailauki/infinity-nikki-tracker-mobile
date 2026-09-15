//
//  LoginView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/17/26.
//

import SwiftUI
import Supabase
import AuthenticationServices

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            Form {
                Section(header: header,footer: ForgotPasswordViewLink()) {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .textContentType(.password)
                        .keyboardType(.default)
                }
                
                Section(footer: SignupViewLink()) {
                    Button("Login") {
                        signIn()
                    }
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .buttonStyle(.plain)
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    }
                    
                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                }
                .foregroundColor(.themeOnPrimary)
                .listRowBackground(Color.themePrimary)
            }
        }
        .navigationTitle("Login")
        .scrollContentBackground(.hidden)
        .background(Color.themeSurface)
    }
    
    // MARK: - View Components
    
    // MARK: - View Components
    
    private var header: some View {
        Text("Enter your email below to login to your account")
            .font(.subheadline)
            .foregroundStyle(Color.themeSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Methods
    
    private func signIn() {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        
        Task {
            do {
                try await supabase.auth.signIn(
                    email: email,
                    password: password
                )
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    LoginView()
}
