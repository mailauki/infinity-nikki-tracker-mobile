//
//  Rarity.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/25/26.
//

import SwiftUI

struct Rarity: View {
    var rarity: Int
    var long: Bool = false
    
    var body: some View {
        if long {
            HStack(spacing: 4) {
                ForEach(1...rarity, id: \.self) { number in
                    Text("✦").rotationEffect(.degrees(15))
                }
            }
        } else {
            HStack(spacing: 4) {
                Text("\(rarity)")
                Text("✦").rotationEffect(.degrees(15))
            }
        }
    }
    
}


#Preview {
    Rarity(rarity: 5)
    Rarity(rarity: 5, long: true)
}
