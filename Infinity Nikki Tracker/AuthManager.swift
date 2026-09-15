//
//  AuthManager.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/15/26.
//

import Foundation
import Supabase

@Observable
final class AuthManager {
    var isAuthenticated = false

    func observeAuthStateChanges() async {
        for await state in supabase.auth.authStateChanges {
            if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                isAuthenticated = state.session != nil
            }
        }
    }
}
