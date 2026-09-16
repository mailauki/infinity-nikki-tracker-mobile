//
//  AppearanceManager.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/16/26.
//

import Supabase
import SwiftUI

@Observable
final class AppearanceManager {
    /// Theme.swift reads `colorTheme` through this shared instance so `Color.theme*`
    /// stays a plain static lookup usable from any call site, while still
    /// participating in SwiftUI's observation tracking when read inside a view body.
    static let shared = AppearanceManager()

    var theme: ThemeMode = .system
    var textScale: TextScale = .default
    var colorTheme: ColorTheme = .terracotta

    var colorScheme: ColorScheme? {
        switch theme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var dynamicTypeSize: DynamicTypeSize {
        switch textScale {
        case .compact: return .small
        case .default: return .large
        case .comfortable: return .xLarge
        case .large: return .xxxLarge
        }
    }

    /// Fetches the signed-in user's saved preferences and applies theme/textScale/colorTheme.
    /// Returns the full row so callers can also read fields this manager doesn't own (e.g. sortOrder).
    @discardableResult
    func load() async -> UserPreferences? {
        do {
            let currentUser = try await supabase.auth.session.user

            let preferences: UserPreferences = try await supabase
                .from("user_preferences")
                .select()
                .eq("user_id", value: currentUser.id)
                .single()
                .execute()
                .value

            theme = preferences.theme ?? .system
            colorTheme = preferences.colorTheme ?? .terracotta
            textScale = preferences.textScale ?? .default

            return preferences
        } catch {
            // No preferences yet — defaults stay in place
            return nil
        }
    }
}
