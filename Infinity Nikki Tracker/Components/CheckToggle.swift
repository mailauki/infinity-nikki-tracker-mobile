//
//  CheckToggle.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/25/26.
//

import SwiftUI

struct CheckToggle: View {
    var isChecked: Bool = false

    var body: some View {
        Toggle(isOn: .constant(isChecked)) {
            if isChecked {
                Image(systemName: "checkmark")
                    .font(.system(size: 16))
                    .bold()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color.themeOnSuccess)
                    .background(Color.themeSuccess)
                    .clipShape(Circle())
                    .overlay(
                            Circle()
                                .strokeBorder(Color.themeTertiary, lineWidth: 1)
                    )
                    .accessibilityLabel(Text("Obtained"))
            } else {
                Image(systemName: "checkmark")
                    .font(.system(size: 16))
                    .bold()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color.themeOutlineVariant)
                    .background(Color.themeSurface)
                    .clipShape(Circle())
                    .overlay(
                            Circle()
                                .strokeBorder(Color.themeOutlineVariant, lineWidth: 1)
                    )
                    .accessibilityLabel(Text("Not Obtained"))
            }
        }
        .toggleStyle(.button)
        .buttonStyle(.plain)
        .padding(5)
    }
}

#Preview {
    CheckToggle(isChecked: true)
    CheckToggle(isChecked: false)
}
