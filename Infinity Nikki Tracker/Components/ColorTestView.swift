//
//  ColorTestView.swift
//  Infinity Nikki Tracker
//
//  Test view to verify all theme colors are properly set up
//

import SwiftUI

struct ColorTestView: View {
    var body: some View {
        NavigationStack {
            List {
                ColorRow(name: "Accent", color: .accent)
                Section("Primary Colors") {
                    ColorRow(name: "themePrimary", color: Color.themePrimary)
                    ColorRow(name: "themeOnPrimary", color: Color.themeOnPrimary)
                    ColorRow(name: "themePrimaryContainer", color: Color.themePrimaryContainer)
                    ColorRow(name: "themeOnPrimaryContainer", color: Color.themeOnPrimaryContainer)
                }
                
                Section("Secondary Colors") {
                    ColorRow(name: "themeSecondary", color: Color.themeSecondary)
                    ColorRow(name: "themeOnSecondary", color: Color.themeOnSecondary)
                    ColorRow(name: "themeSecondaryContainer", color: Color.themeSecondaryContainer)
                    ColorRow(name: "themeOnSecondaryContainer", color: Color.themeOnSecondaryContainer)
                }
                
                Section("Tertiary Colors") {
                    ColorRow(name: "themeTertiary", color: Color.themeTertiary)
                    ColorRow(name: "themeOnTertiary", color: Color.themeOnTertiary)
                    ColorRow(name: "themeTertiaryContainer", color: Color.themeTertiaryContainer)
                    ColorRow(name: "themeOnTertiaryContainer", color: Color.themeOnTertiaryContainer)
                }
                
                Section("Error Colors") {
                    ColorRow(name: "themeError", color: Color.themeError)
                    ColorRow(name: "themeOnError", color: Color.themeOnError)
                    ColorRow(name: "themeErrorContainer", color: Color.themeErrorContainer)
                    ColorRow(name: "themeOnErrorContainer", color: Color.themeOnErrorContainer)
                }
                
                Section("Success Colors") {
                    ColorRow(name: "themeSuccess", color: Color.themeSuccess)
                    ColorRow(name: "themeOnSuccess", color: Color.themeOnSuccess)
                    ColorRow(name: "themeSuccessContainer", color: Color.themeSuccessContainer)
                    ColorRow(name: "themeOnSuccessContainer", color: Color.themeOnSuccessContainer)
                }
                
                Section("Surface Colors") {
                    ColorRow(name: "themeSurface", color: Color.themeSurface)
                    ColorRow(name: "themeSurfaceDim", color: Color.themeSurfaceDim)
                    ColorRow(name: "themeSurfaceBright", color: Color.themeSurfaceBright)
                    ColorRow(name: "themeSurfaceContainerLowest", color: Color.themeSurfaceContainerLowest)
                    ColorRow(name: "themeSurfaceContainerLow", color: Color.themeSurfaceContainerLow)
                    ColorRow(name: "themeSurfaceContainer", color: Color.themeSurfaceContainer)
                    ColorRow(name: "themeSurfaceContainerHigh", color: Color.themeSurfaceContainerHigh)
                    ColorRow(name: "themeSurfaceContainerHighest", color: Color.themeSurfaceContainerHighest)
                    ColorRow(name: "themeOnSurface", color: Color.themeOnSurface)
                    ColorRow(name: "themeOnSurfaceVariant", color: Color.themeOnSurfaceVariant)
                    ColorRow(name: "themeSurfaceVariant", color: .themeSurfaceVariant)
                    ColorRow(name: "themeInverseSurface", color: Color.themeInverseSurface)
                    ColorRow(name: "themeOnInverseSurface", color: Color.themeOnInverseSurface)
                }
                
                Section("Outline Colors") {
                    ColorRow(name: "themeOutline", color: Color.themeOutline)
                    ColorRow(name: "themeOutlineVariant", color: Color.themeOutlineVariant)
                }
                
                Section("Other") {
                    ColorRow(name: "themeInversePrimary", color: Color.themeInversePrimary)
                }
                
                Section("Component Tests") {
                    VStack(spacing: 16) {
                        ProgressChip(progress: 1.0)
                        ProgressChip(progress: 0.5)
                        
                        Chip(label: "Test Chip")
                        
                        CheckToggle( isChecked: true)
                        CheckToggle( isChecked: false)
                        
                        RarityStars(rarity: 5)
                    }
                    .padding()
                }
            }
            .navigationTitle("Color Test")
        }
    }
}

struct ColorRow: View {
    let name: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(name)
                .font(.caption)
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 60, height: 30)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

#Preview {
    ColorTestView()
}
