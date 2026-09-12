//
//  EurekaSetRow.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/25/26.
//

import SwiftUI

struct EurekaSetRow: View {
    var eurekaSet: EurekaSet
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: eurekaSet.imageURL ?? "")) { phase in
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
            
            VStack(alignment: .leading) {
                Text(eurekaSet.title)
                    .font(.headline)
                    .foregroundStyle(Color.themeOnSurface)
                
                if let rarity = eurekaSet.rarity {
                    Rarity(rarity: rarity)
                }
            }
            
            Spacer()
        }
        .overlay(alignment: .topTrailing) {
            if let label = eurekaSet.label {
                Chip(label: label)
            }
        }
    }
}
