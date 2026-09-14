//
//  ContentView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 1/28/26.
//

import SwiftUI
import Supabase

struct ContentView: View {
    @State private var isAuthenticated = false
    
    var body: some View {
        Group {
            if isAuthenticated {
                authenticatedView
            } else {
                unauthenticatedView
            }
        }
        .task {
            await observeAuthStateChanges()
        }
    }
    
    // MARK: - View Components
    
    private var authenticatedView: some View {
        TabView {
            Tab("Home", systemImage: "sparkle") {
            Text("Home View")
        }
            Tab("Outfits", image: "outfits") {
                OutfitsView()
            }
            Tab("Eureka", image: "eureka") {
                EurekaView()
            }
            
            Tab("Profile", systemImage: "person.fill") {
                ProfileView()
            }
        }
    }
    
    private var unauthenticatedView: some View {
        NavigationStack {
            WelcomeView()
        }
    }
    
    // MARK: - Methods
    
    private func observeAuthStateChanges() async {
        for await state in supabase.auth.authStateChanges {
            if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                isAuthenticated = state.session != nil
            }
        }
    }
}

#Preview {
    ContentView()
}
