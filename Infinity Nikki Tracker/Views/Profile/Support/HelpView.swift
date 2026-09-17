//
//  HelpView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/16/26.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("This is the Help view.")
                .font(.body)
        }
    }
}

#Preview {
    HelpView()
}
