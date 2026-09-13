//
//  EurekaRow.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/25/26.
//

import SwiftUI

struct EurekaRow: View {
    var eurekaVariant: EurekaVariant
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: eurekaVariant.imageURL ?? "")) { phase in
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
                Text("\(eurekaVariant.category ?? "Unknown") • \(eurekaVariant.color ?? "Unknown")")
                    .font(.headline)
                    .foregroundStyle(Color.themeOnSurface)
                
                if let eurekaSet = eurekaVariant.eurekaSet {
                    Text(eurekaSet)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            CheckToggle(isChecked: eurekaVariant.obtained ?? false)
        }
    }
}
