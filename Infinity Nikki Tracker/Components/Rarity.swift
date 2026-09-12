//
//  Rarity.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/25/26.
//

import SwiftUI

struct Rarity: View {
    var rarity: Int
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(1...rarity, id: \.self) { number in
                Image(systemName: "sparkle")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .rotationEffect(.degrees(15))
            }
            .foregroundStyle(Color.themeSecondary)
        }
    }
    
}


#Preview {
    Rarity(rarity: 5)
}
