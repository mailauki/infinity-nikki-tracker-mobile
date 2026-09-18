//
//  CompletionProgress.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/13/26.
//

import SwiftUI

enum Size {
    case long, short, mini
}

struct CompletionProgress: View {
    let obtained: Int
    let total: Int
    var size: Size = .long
    
    var body: some View {
        HStack {
            if size == .long || size == .short {
                Image(systemName: obtained == total ? "circle.fill" : "circle")
                    .resizable()
                    .frame(width: 8, height: 8)
            }
            
            if size == .long {
                Text("\(obtained)/\(total) \(obtained == total ? "complete" : "pieces")")
                    .font(.caption)
            } else {
                Text("\(obtained)/\(total)")
                    .font(.caption)
            }
        }
        .foregroundStyle(obtained == total ? Color.themeSuccess : Color.secondary)
    }
}

#Preview {
    CompletionProgress(obtained: 8, total: 8)
    CompletionProgress(obtained: 1, total: 4)
    CompletionProgress(obtained: 1, total: 4, size: .short)
    CompletionProgress(obtained: 8, total: 8, size: .mini)
}
