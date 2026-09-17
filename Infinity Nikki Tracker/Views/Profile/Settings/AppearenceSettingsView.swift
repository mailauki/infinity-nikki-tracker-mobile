//
//  AppearenceSettingsView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/16/26.
//

import SwiftUI
import Supabase

struct AppearenceSettingsView: View {
    @Environment(AppearanceManager.self) private var appearanceManager
    
    @State private var sortOrder: DefaultSortOrder = .newest
    @State private var isLoadingPreferences = false
    @State private var preferencesError: String?
    
    var body: some View {
        List {
            modeSection
            textScaleSection
            sortOrderSection
            colorThemeSection
        }
        .scrollContentBackground(.hidden)
        .background(Color.themeSurface)
        .disabled(isLoadingPreferences)
        .overlay {
            if isLoadingPreferences {
                ProgressView()
            }
        }
        .task {
            await loadPreferences()
        }
        .onChange(of: appearanceManager.theme) { _, _ in
            guard !isLoadingPreferences else { return }
            updatePreferences()
        }
        .onChange(of: appearanceManager.textScale) { _, _ in
            guard !isLoadingPreferences else { return }
            updatePreferences()
        }
        .onChange(of: appearanceManager.colorTheme) { _, _ in
            guard !isLoadingPreferences else { return }
            updatePreferences()
        }
        .onChange(of: sortOrder) { _, _ in
            guard !isLoadingPreferences else { return }
            updatePreferences()
        }
        .alert(
            "Couldn't Save Appearance",
            isPresented: Binding(
                get: { preferencesError != nil },
                set: { if !$0 { preferencesError = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(preferencesError ?? "")
        }
    }
    
    // MARK: - Appearance Sections
    
    private var themeBinding: Binding<ThemeMode> {
        Binding(
            get: { appearanceManager.theme },
            set: { appearanceManager.theme = $0 }
        )
    }
    
    private var textScaleBinding: Binding<TextScale> {
        Binding(
            get: { appearanceManager.textScale },
            set: { appearanceManager.textScale = $0 }
        )
    }
    
    private var modeSection: some View {
        Section("Mode") {
            Picker("Mode", selection: themeBinding) {
                ForEach(ThemeMode.allCases) { mode in
                    SwiftUI.Label(mode.label, systemImage: mode.systemImage)
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
        .foregroundColor(Color.themeOnSurface)
        .listRowBackground(Color.themeSurfaceContainerLowest)
    }
    
    private var textScaleSection: some View {
        Section {
            Picker("Text Size", selection: textScaleBinding) {
                ForEach(TextScale.allCases) { scale in
                    Text(scale.label)
                        .tag(scale)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        } header: {
            Text("Text Size")
        } footer: {
            Text("Scales text across the whole app, including collection grids and filters.")
        }
        .foregroundColor(Color.themeOnSurface)
        .listRowBackground(Color.themeSurfaceContainerLowest)
    }
    
    private var sortOrderSection: some View {
        Section {
            Picker("Default Sort", selection: $sortOrder) {
                ForEach(DefaultSortOrder.allCases) { order in
                    Text(order.label)
                        .tag(order)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        } header: {
            Text("Default Sort")
        } footer: {
            Text("Applies to the Eureka and Outfits collection views.")
        }
        .foregroundColor(Color.themeOnSurface)
        .listRowBackground(Color.themeSurfaceContainerLowest)
    }
    
    private var colorThemeSection: some View {
        Section("Color Theme") {
            ForEach(ColorTheme.allCases) { option in
                Button {
                    appearanceManager.colorTheme = option
                } label: {
                    ThemePickerCard(title: option.title, subtitle: option.subtitle, isSelected: appearanceManager.colorTheme == option)
                }
                .buttonStyle(.plain)
            }
        }
        .foregroundColor(Color.themeOnSurface)
        .listRowBackground(Color.themeSurfaceContainerLowest)
    }
    
    struct ThemePickerCard: View {
        let title: String
        let subtitle: String
        var isSelected: Bool = false
        
        var body: some View {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    HStack {
                        Circle().fill(Color("Theme/\(title)/Primary/Main"))
                            .frame(width: 20)
                        Circle().fill(Color("Theme/\(title)/Secondary/Main"))
                            .frame(width: 20)
                        Circle().fill(Color("Theme/\(title)/Tertiary/Main"))
                            .frame(width: 20)
                    }
                    Text(title)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundColor(Color.themeOnSurfaceVariant)
                }
                Spacer()
                CheckToggle(isChecked: isSelected)
            }
        }
    }
    
    // MARK: - Methods
    
    private func loadPreferences() async {
        isLoadingPreferences = true
        defer { isLoadingPreferences = false }
        if let preferences = await appearanceManager.load() {
            sortOrder = preferences.sortOrder ?? .newest
        }
    }
    
    private func updatePreferences() {
        Task {
            preferencesError = nil
            do {
                let currentUser = try await supabase.auth.session.user
                
                struct PreferencesUpdate: Encodable {
                    let userId: UUID
                    let theme: String
                    let colorTheme: String
                    let sortOrder: String
                    let textScale: String
                    let updatedAt: String
                    enum CodingKeys: String, CodingKey {
                        case userId = "user_id"
                        case theme
                        case colorTheme = "color_theme"
                        case sortOrder = "sort_order"
                        case textScale = "text_scale"
                        case updatedAt = "updated_at"
                    }
                }
                
                let updates = PreferencesUpdate(
                    userId: currentUser.id,
                    theme: appearanceManager.theme.rawValue,
                    colorTheme: appearanceManager.colorTheme.rawValue,
                    sortOrder: sortOrder.rawValue,
                    textScale: appearanceManager.textScale.rawValue,
                    updatedAt: ISO8601DateFormatter().string(from: Date())
                )
                
                try await supabase
                    .from("user_preferences")
                    .upsert(updates, onConflict: "user_id")
                    .execute()
            } catch {
                preferencesError = "Failed to save: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    AppearenceSettingsView()
}
