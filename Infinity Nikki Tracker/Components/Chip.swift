//
//  Chip.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/25/26.
//

import SwiftUI

struct Chip: View {
    var label: String
    
    var body: some View {
        Text(label.capitalized)
            .font(.footnote)
            .foregroundStyle(Color.themeOnSurface)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .overlay(
                Capsule()
                    .stroke(Color.themeOutline, lineWidth: 0.5)
            )
    }
}

#Preview {
    Chip(label: "hello")
}
