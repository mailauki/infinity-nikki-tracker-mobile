//
//  SettingsView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/11/26.
//

import PhotosUI
import Supabase
import SwiftUI

enum MenuOption: Hashable, CaseIterable {
    case profile
    case appearence
    case settings
    case about
    case help
    
    var title: String {
        switch self {
        case .profile: return "Profile Settings"
        case .appearence: return "Appearence"
        case .settings: return "Preferences"
        case .about: return "About This App"
        case .help: return "Help & Support"
        }
    }
    
    var icon: String {
        switch self {
        case .profile: return "person.crop.circle"
        case .appearence: return "paintpalette"
        case .settings: return "gearshape"
        case .about: return "info.circle"
        case .help: return "questionmark.circle"
        }
    }
    
    @ViewBuilder
    var currentView: some View {
        switch self {
        case .profile: ProfileSettingsView()
        case .appearence: AppearenceSettingsView()
        case .settings: AccountSettingsView()
        case .about: AboutView()
        case .help: HelpView()
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                Section(header: Text("Account & System")) {
                    ForEach(MenuOption.allCases, id: \.self) { option in
                        NavigationLink(value: option) {
                            SwiftUI.Label(option.title, systemImage: option.icon)
                        }
                    }
                }
            }
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Done button to close the sheet easily
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(for: MenuOption.self) { option in
                DestinationDetailView(option: option)
            }
        }
    }
}

struct DestinationDetailView: View {
    let option: MenuOption
    
    var body: some View {
        option.currentView
            .navigationTitle(option.title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView().environment(AppearanceManager.shared)
}
