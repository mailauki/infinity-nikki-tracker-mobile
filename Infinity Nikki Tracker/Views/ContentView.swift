//
//  ContentView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 1/28/26.
//

import SwiftUI

enum AppTab: Hashable {
    case home, seasons, profile
}

struct ContentView: View {
    @State private var authManager = AuthManager()
    @State private var appearanceManager = AppearanceManager.shared
    
    //    @State private var selectedTab: AppTab = .home
    @State private var showHome: Bool = true
    @State private var isMenuShowing = false
//    
    var body: some View {
        //        TabView(selection: $selectedTab) {
        //            Tab("Home", systemImage: "sparkle", value: .home) {
        //                HomeView(selectedTab: $selectedTab)
        //            }
        //
        //            Tab("Seasons", image: "compendium", value: .seasons) {
        //                SeasonsView()
        //            }
        //
        //            if authManager.isAuthenticated {
        //                Tab("Profile", systemImage: "person.fill", value: .profile) {
        //                    ProfileView()
        //                }
        //            }
        //        }
//        NavigationStack {
//            Group {
//                if showHome {
//                    Text("Home")
//                } else {
//                    SeasonsView()
//                }
//            }
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button {
//                        isMenuShowing = true
//                    } label: {
//                        Image(systemName: "line.horizontal.3")
//                    }
//                }
//            }
//            .sheet(isPresented: $isMenuShowing) {
//                NavigationStack {
//                    List {
//                        Button(action: { print("Log out") }) {
//                            SwiftUI.Label("Share Profile", systemImage: "square.and.arrow.up")
//                        }
//                        Button(action: { print("Log out") }) {
//                            SwiftUI.Label("Add to Favorites", systemImage: "star")
//                        }
//                        Button(role: .destructive, action: { print("Log out") }) {
//                            SwiftUI.Label("Delete Item", systemImage: "trash")
//                        }
//                        //                        NavigationLink {
//                        //                            Text("Outfits")
//                        //                        } label: {
//                        //                            SwiftUI.Label("Outfits", image: "outfits")
//                        //                        }
//                        //                        NavigationLink {
//                        //                            Text("Eureka")
//                        //                        } label: {
//                        //                            SwiftUI.Label("Eureka", image: "eureka")
//                        //                        }
//                    }
//                }
//            }
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    // Native SwiftUI Menu block
//                    Menu {
//                        NavigationLink {
//                            Text("Outfits")
//                        } label: {
//                            SwiftUI.Label("Outfits", image: "outfits")
//                        }
//                        NavigationLink {
//                            Text("Eureka")
//                        } label: {
//                            SwiftUI.Label("Eureka", image: "eureka")
//                        }
//                    } label: {
//                        // The Hamburger Icon
//                        Image(systemName: "line.horizontal.3")
//                            .imageScale(.large)
//                    }
//                }
//                ToolbarItem(placement: .topBarTrailing) {
//                    // Native SwiftUI Menu block
//                    Menu {
//                        NavigationLink {
//                            ProfileView()
//                        } label: {
//                            SwiftUI.Label("Profile", systemImage: "person.crop.circle")
//                        }
//                        NavigationLink {
//                            SettingsView()
//                        } label: {
//                            SwiftUI.Label("Settings", systemImage: "gearshape")
//                        }
//                        
//                        Divider()
//                        
//                        Button(role: .destructive, action: { print("Log out") }) {
//                            SwiftUI.Label("Log Out", systemImage: "arrow.left.circle")
//                        }
//                    } label: {
//                        Image(systemName: "person.fill")
//                            .imageScale(.large)
//                    }
//                }
//                ToolbarItem(placement: .principal) {
//                    Picker("View", selection: $showHome) {
//                        Text("Home").tag(true)
//                        Text("Seasons").tag(false)
//                    }
//                    .pickerStyle(.segmented)
//                    .frame(width: 160)
//                }
//            }
        Group {
            Text("Hello, World!")
        }
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

#Preview {
    ContentView()
}
