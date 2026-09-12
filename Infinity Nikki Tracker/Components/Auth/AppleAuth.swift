//
//  AppleAuth.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/17/26.
//
import SwiftUI
import Supabase
import AuthenticationServices
import CryptoKit

struct AppleAuth: View {
    var variant: SignInWithAppleButton.Label
    
    @Environment(\.colorScheme) private var colorScheme
    
    // Determine the button style based on the color scheme
    private var appleButtonStyle: SignInWithAppleButton.Style {
        switch colorScheme {
        case .light:
            return .black
        case .dark:
            return .white
        @unknown default:
            return .black
        }
    }
    
    var body: some View {
        VStack {
            SignInWithAppleButton(variant) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                // ...
            }
            .signInWithAppleButtonStyle(appleButtonStyle)
            .frame(width: 380, height: 44)
            .cornerRadius(10)
            .padding(.vertical)
            .id(colorScheme)
        }
    }
    
//    func signInWithApple(idToken: String, nonce: String) async throws {
//        try await supabase.auth.signInWithIdToken(credentials: OpenIDConnectCredentials(provider: .apple, idToken: idToken, nonce: nonce))
//    }
}

#Preview {
    AppleAuth(variant: .signUp)
    AppleAuth(variant: .signIn)
    AppleAuth(variant: .continue)
}
