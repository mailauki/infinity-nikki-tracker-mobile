//
//  EurekaSetCard.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/20/26.
//

import SwiftUI

struct EurekaSetCard: View {
    let eurekaSet: EurekaSet
    
    var body: some View {
//            VStack(alignment: .leading) {
//                AsyncImage(url: URL(string: "\(eurekaSet.eurekaVariants.first(where: { $0.isDefault == true })?.imageURL ?? "")")) { phase in
//                    if let image = phase.image {
//                        image
//                            .resizable()
//                            .scaledToFit()
//                    } else if phase.error != nil {
//                        Image(systemName: "photo.fill")
//                            .resizable()
//                            .frame(width: 60, height: 40)
//                            .foregroundStyle(.placeholder.opacity(0.5))
//                    } else {
//                        ProgressView()
//                    }
//                }
//                .frame(width: 100, height: 100)
//                
//                Text("\(eurekaSet.title)")
//                    .padding(.vertical, 6)
//                
//                Rarity(rarity: eurekaSet.rarity ?? 0)
//                
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .overlay(alignment: .topTrailing) {
//                Chip(label: eurekaSet.label ?? "")
//            }
//            .padding(10)
//            .background(Color.themeSurfaceBright)
//            .foregroundColor(Color.themeOnSurface)
//            .cornerRadius(16)
//            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 3, y: 3)
        CardView(eurekaSet: eurekaSet)
        }
}
