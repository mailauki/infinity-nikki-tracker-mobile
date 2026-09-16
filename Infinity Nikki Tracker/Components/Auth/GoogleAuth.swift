//
//  GoogleAuth.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/11/26.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct GoogleAuth: View {
    @State private var loginError: String?

    var body: some View {
        // The official Google Sign-In Button
        GoogleSignInButton(scheme: .light, style: .standard, state: .normal) {
            handleGoogleSignIn()
        }
        //            .frame(width: 280, height: 45)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(width: 380, height: 44)
        
        if let error = loginError {
            Text(error)
                .foregroundColor(.red)
                .font(.caption)
        }
    }
    
    private func handleGoogleSignIn() {
        // 1. Get the root view controller needed to present the sign-in modal
        guard let rootViewController = UIApplication.shared.rootViewController else {
            self.loginError = "Unable to find root view controller."
            return
        }
        
        // 2. Trigger the Google Sign-In flow
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error = error {
                self.loginError = "Authentication failed: \(error.localizedDescription)"
                return
            }
            
            guard let result = signInResult else { return }
            
            // 3. Success! Access the user's information
            let user = result.user
            let email = user.profile?.email
            let fullName = user.profile?.name
            print("Successfully signed in as \(fullName ?? "") with email \(email ?? "")")
            
            // (Optional) If you are using Firebase, use the credentials here:
            // let credential = GoogleAuthProvider.credential(withIDToken: user.idToken?.tokenString, accessToken: user.accessToken.tokenString)
        }
    }
}

extension UIApplication {
    var rootViewController: UIViewController? {
        let windowScene = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        
        return windowScene?.windows
            .first(where: { $0.isKeyWindow })?
            .rootViewController
    }
}

#Preview {
    GoogleAuth()
}
