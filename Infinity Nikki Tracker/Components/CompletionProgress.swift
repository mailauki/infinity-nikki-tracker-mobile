//
//  CompletionProgress.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/13/26.
//

import SwiftUI

struct CompletionProgress: View {
    let obtained: Int
    let total: Int
    
    var body: some View {
        HStack {
            Image(systemName: obtained == total ? "circle.fill" : "circle")
                .resizable()
                .frame(width: 8, height: 8)
            Text("\(obtained)/\(total) \(obtained == total ? "complete" : "pieces")")
                .font(.caption)
        }
        .foregroundStyle(obtained == total ? Color.themeSuccess : Color.secondary)
    }
}

#Preview {
    CompletionProgress(obtained: 8, total: 8)
    CompletionProgress(obtained: 1, total: 4)
}
