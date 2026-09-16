//
//  SignupView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/17/26.
//

import SwiftUI
import Supabase
import AuthenticationServices

struct SignupView: View {
    @State var email = ""
    @State var password = ""
    @State var repeatPassword = ""
    @State var isLoading = false
    @State var result: Result<Void, Error>?
    
    var body: some View {
        VStack {
            Form {
                Section(header: header) {
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
                    
                    SecureField("Repeat Password", text: $repeatPassword)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .textContentType(.password)
                        .keyboardType(.default)
                }
                .foregroundColor(.themeOnSurface)
                .listRowBackground(Color.themeSurfaceContainerLowest)
                
                Section(footer: LoginViewLink()) {
                    Button("Signup") {
                        signUp()
                    }
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .buttonStyle(.plain)
                    .bold()
                }
                .foregroundColor(.themeOnPrimary)
                .listRowBackground(Color.themePrimary)
            }
        }
        .navigationTitle("Signup")
//        .toolbar {
//            ToolbarItem(placement: .topBarLeading) {
//                NavigationLink {
//                    HomeView()
//                } label: {
//                    Image(systemName: "chevron.backward")
//                        .accessibilityLabel("Back")
//                }
//            }
//        }
//        .navigationBarBackButtonHidden(true)
        .scrollContentBackground(.hidden)
        .background(Color.themeSurface)
    }
    
    private var header: some View {
        Text("Create a new account")
            .font(.subheadline)
            .foregroundStyle(Color.themeSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func signUp() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await supabase.auth.signUp(
                    email: "valid.email@supabase.io",
                    password: "example-password",
                    redirectTo: URL(string: "https://example.com/welcome")
                )
                result = .success(())
            } catch {
                result = .failure(error)
            }
        }
    }
}

#Preview {
    SignupView()
}
