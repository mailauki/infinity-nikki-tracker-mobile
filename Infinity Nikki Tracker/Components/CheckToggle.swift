//
//  CheckToggle.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/25/26.
//

import SwiftUI

struct CheckToggle: View {
    enum Size {
        case sm, md

        var iconSize: CGFloat { self == .sm ? 11 : 16 }
        var frameSize: CGFloat { self == .sm ? 20 : 30 }
    }

    var isChecked: Bool = false // TODO: Add toggle obtained (set/variant) functionality
    var size: Size = .md

    var body: some View {
        Toggle(isOn: .constant(isChecked)) {
            Image(systemName: "checkmark")
                .font(.system(size: size.iconSize))
                .bold()
                .frame(width: size.frameSize, height: size.frameSize)
                .foregroundColor(isChecked ? Color.themeOnSuccess : Color.themeOutlineVariant)
                .background(isChecked ? Color.themeSuccess : Color.themeSurface)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .strokeBorder(isChecked ? Color.themeSuccess : Color.themeOutlineVariant, lineWidth: 1)
                )
                .accessibilityLabel(Text(isChecked ? "Obtained" : "Not Obtained"))
        }
        .toggleStyle(.button)
        .buttonStyle(.plain)
        .padding(5)
    }
}

#Preview {
    CheckToggle(isChecked: true)
    CheckToggle(isChecked: false)
    CheckToggle(isChecked: true, size: .sm)
}
