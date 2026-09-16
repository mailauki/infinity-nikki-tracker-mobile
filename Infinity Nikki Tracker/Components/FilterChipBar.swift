//
//  FilterChipBar.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/15/26.
//

import SwiftUI

struct FilterOption: Identifiable, Hashable {
    let id: String
    let label: String
    var imageName: String? = nil
}

struct FilterChipBar: View {
    let options: [FilterOption]
    @Binding var selection: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(options) { option in
                    let isSelected = selection == option.id

                    Button {
                        selection = option.id
                    } label: {
                        HStack(spacing: 6) {
                            if let imageName = option.imageName {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14, height: 14)
                                    .clipShape(Circle())
                            }

                            Text(option.label)
                        }
                        .font(.footnote)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundStyle(isSelected ? Color.themeOnPrimary : Color.themeOnSurface)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isSelected ? Color.themePrimary : Color.clear)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(isSelected ? Color.clear : Color.themeOutline, lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    @Previewable @State var selection = "all"
    FilterChipBar(options: [
        FilterOption(id: "all", label: "All"),
        FilterOption(id: "red", label: "Red", imageName: "red"),
        FilterOption(id: "blue", label: "Blue", imageName: "blue"),
        FilterOption(id: "green", label: "Green", imageName: "green"),
        FilterOption(id: "glowup", label: "✦ Glowup")
    ], selection: $selection)
}
