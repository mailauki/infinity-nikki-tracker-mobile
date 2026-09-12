//
//  ProgressChip.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/10/26.
//

import SwiftUI

struct ProgressChip: View {
    var progress: Float
    
    var body: some View {
        if progress == 1 {
            Text("Complete".uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.themeSuccess)
                .foregroundColor(Color.themeOnSuccess)
                .clipShape(Capsule())
        } else {
            Text("Unfinished".uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.themeSurfaceContainer)
                .foregroundColor(Color.themeOnSurface)
                .clipShape(Capsule())
        }
    }
}

#Preview("Complete") {
    VStack(spacing: 20) {
        ProgressChip(progress: 1.0)
            .background(Color.gray.opacity(0.2))
        
        ProgressChip(progress: 0.5)
            .background(Color.gray.opacity(0.2))
    }
    .padding()
}


