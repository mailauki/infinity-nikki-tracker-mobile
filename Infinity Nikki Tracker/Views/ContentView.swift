//
//  ContentView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 1/28/26.
//

import SwiftUI

struct ContentView: View {
    @State private var authManager = AuthManager()

    var body: some View {
        TabView {
            Tab("Home", systemImage: "sparkle") {
                HomeView()
            }

            Tab("Outfits", image: "outfits") {
                OutfitsView()
            }
            Tab("Eureka", image: "eureka") {
                EurekaView()
            }

            if authManager.isAuthenticated {
                Tab("Profile", systemImage: "person.fill") {
                    ProfileView()
                }
            }
        }
        .environment(authManager)
        .task {
            await authManager.observeAuthStateChanges()
        }
    }
}

#Preview {
    ContentView()
}
