//
//  ForgotPasswordView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/19/26.
//

import SwiftUI
import Supabase
import AuthenticationServices

struct ForgotPasswordView: View {
    @State var email = ""
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
                }
                
                Section(footer: LoginViewLink()) {
                    Button("Send reset email") {
                        resetPassword()
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
        .navigationTitle("Reset Your Password")
//        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .background(Color.themeSurface)
    }
    
    private var header: some View {
        Text("Type in your email and we'll send you a link to reset your password")
            .font(.subheadline)
            .foregroundStyle(Color.themeSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func resetPassword() {
        print("Password reset requested for \(email)")
    }
}

#Preview {
    ForgotPasswordView()
}
