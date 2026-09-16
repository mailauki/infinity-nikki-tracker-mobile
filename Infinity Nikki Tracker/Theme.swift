//
//  Theme.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/10/26.
//

import SwiftUI

extension Color {
    /// The active color theme's asset subfolder, e.g. "Terracotta" or "Cherry Blossom".
    /// Reading `colorTheme` here lets SwiftUI's observation tracking pick up
    /// changes made through `AppearanceManager`, even though these are static lookups.
    private static var themeFolder: String {
        AppearanceManager.shared.colorTheme.assetFolder
    }

    private static func theme(_ path: String) -> Color {
        Color("Theme/\(themeFolder)/\(path)")
    }

    static let primary = Color("Theme/Terracotta/Main")

    // MARK: - Primary Colors

    static var themePrimary: Color { theme("Primary/Main") }
    static var themeOnPrimary: Color { theme("Primary/On") }
    static var themePrimaryContainer: Color { theme("Primary/Container") }
    static var themeOnPrimaryContainer: Color { theme("Primary/OnContainer") }

    // MARK: - Secondary Colors

    static var themeSecondary: Color { theme("Secondary/Main") }
    static var themeOnSecondary: Color { theme("Secondary/On") }
    static var themeSecondaryContainer: Color { theme("Secondary/Container") }
    static var themeOnSecondaryContainer: Color { theme("Secondary/OnContainer") }

    // MARK: - Tertiary Colors

    static var themeTertiary: Color { theme("Tertiary/Main") }
    static var themeOnTertiary: Color { theme("Tertiary/On") }
    static var themeTertiaryContainer: Color { theme("Tertiary/Container") }
    static var themeOnTertiaryContainer: Color { theme("Tertiary/OnContainer") }

    // MARK: - Error Colors

    static var themeError: Color { theme("Error/Main") }
    static var themeOnError: Color { theme("Error/On") }
    static var themeErrorContainer: Color { theme("Error/Container") }
    static var themeOnErrorContainer: Color { theme("Error/OnContainer") }

    // MARK: - Success Colors (Custom)

    static var themeSuccess: Color { theme("Success/Main") }
    static var themeOnSuccess: Color { theme("Success/On") }
    static var themeSuccessContainer: Color { theme("Success/Container") }
    static var themeOnSuccessContainer: Color { theme("Success/OnContainer") }

    // MARK: - Surface Colors

    static var themeSurface: Color { theme("Surface/Main") }
    static var themeSurfaceDim: Color { theme("Surface/Dim") }
    static var themeSurfaceBright: Color { theme("Surface/Bright") }
    static var themeSurfaceContainerLowest: Color { theme("Surface/ContainerLowest") }
    static var themeSurfaceContainerLow: Color { theme("Surface/ContainerLow") }
    static var themeSurfaceContainer: Color { theme("Surface/Container") }
    static var themeSurfaceContainerHigh: Color { theme("Surface/ContainerHigh") }
    static var themeSurfaceContainerHighest: Color { theme("Surface/ContainerHighest") }
    static var themeOnSurface: Color { theme("Surface/On") }
    static var themeOnSurfaceVariant: Color { theme("Surface/OnVariant") }
    static var themeSurfaceVariant: Color { theme("Surface/Variant") }
    static var themeInverseSurface: Color { theme("Surface/Inverse") }
    static var themeOnInverseSurface: Color { theme("Surface/OnInverse") }

    // MARK: - Outline Colors

    static var themeOutline: Color { theme("Outline/Main") }
    static var themeOutlineVariant: Color { theme("Outline/Variant") }

    // MARK: - Inverse Primary

    static var themeInversePrimary: Color { theme("Primary/Inverse") }
}
