//
//  ContentView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 1/28/26.
//

import SwiftUI

struct ContentView: View {
    @State private var authManager = AuthManager()
    @State private var appearanceManager = AppearanceManager.shared
    
    var body: some View {
        TabView {
            Tab("Seasons", image: "compendium") {
                NavigationStack {
                    SeasonsView()
                        .profileMenuToolbar(authManager: authManager)
                }
            }

            Tab("Outfits", image: "outfits") {
                NavigationStack {
                    OutfitsView()
                        .profileMenuToolbar(authManager: authManager)
                }
            }

            Tab("Eureka", image: "eureka") {
                NavigationStack {
                    EurekaView()
                        .profileMenuToolbar(authManager: authManager)
                }
            }

            Tab("Makeup", image: "makeup") {
                NavigationStack {
                    MakeupView()
                        .profileMenuToolbar(authManager: authManager)
                }
            }

            Tab("Cloaks", image: "momo-cloak") {
                NavigationStack {
                    CloaksView()
                        .profileMenuToolbar(authManager: authManager)
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .environment(authManager)
        .environment(appearanceManager)
        .preferredColorScheme(appearanceManager.colorScheme)
        .dynamicTypeSize(appearanceManager.dynamicTypeSize)
        .task {
            await authManager.observeAuthStateChanges()
        }
        .task {
            await appearanceManager.load()
        }
    }
}

private extension View {
    @ViewBuilder
    func profileMenuToolbar(authManager: AuthManager) -> some View {
        toolbar {
            if authManager.isAuthenticated {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        NavigationLink {
                            ProfileView()
                        } label: {
                            SwiftUI.Label("Profile", systemImage: "person.crop.circle")
                        }
                        NavigationLink {
                            SettingsView()
                        } label: {
                            SwiftUI.Label("Settings", systemImage: "gearshape")
                        }

                        Divider()

                        Button(role: .destructive, action: { print("Log out") }) { // TODO
                            SwiftUI.Label("Log Out", systemImage: "arrow.left.circle")
                        }
                    } label: {
                        Image(systemName: "person.fill")
                            .imageScale(.large)
                    }
                }
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink("Login") {
                        LoginView()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
