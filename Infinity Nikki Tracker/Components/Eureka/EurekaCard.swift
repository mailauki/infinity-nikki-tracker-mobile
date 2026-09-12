//
//  EurekaCard.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/19/26.
//

import SwiftUI

struct EurekaCard: View {
    let eurekaVariant: EurekaVariant
    
    var body: some View {
        Button(action: {
            print("Custom card button tapped!")
        }) {
            // The custom card appearance
            VStack(alignment: .leading) {
                AsyncImage(url: URL(string: "\(eurekaVariant.imageURL ?? "")")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                    } else if phase.error != nil {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .frame(width: 60, height: 40)
                            .foregroundStyle(.placeholder.opacity(0.5))
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 80, height: 80)
                
                Text("\(eurekaVariant.category) • \(eurekaVariant.color)").lineLimit(1)
                    .font(.caption)
            }
            .padding()
            .background(Color.themeSurfaceBright)
            .foregroundColor(Color.themeOnSurface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 3, y: 3)
        }
        // Use .plain or .borderless to ensure the custom style isn't overridden by default styles
        .buttonStyle(.plain)
        // Ensure the entire card is tappable
        .contentShape(Rectangle())
    }
}
