//
//  AuthBanner.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/15/26.
//

import SwiftUI

struct AuthBanner: View {
    let collectionLabel: String?
    
    init(collectionLabel: String? = nil) {
        self.collectionLabel = collectionLabel
    }
    
    var body: some View {
        HStack {
            Image(systemName: "info.circle")
                .font(.title2)
                .foregroundColor(Color.themePrimary)
            
            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 0) {
                    NavigationLink("Login") {
                        LoginView()
                    }
                    .underline()
                    Text(" or ")
                    NavigationLink("Sign up") {
                        SignupView()
                    }
                    .underline()
                }
                Group {
                    if let collectionLabel {
                        Text("to track your collected \(collectionLabel)")
                    } else {
                        Text("to track your collection")
                    }
                }
            }
            .font(.subheadline)
            Spacer()
        }
        .foregroundColor(Color.themeOnPrimaryContainer)
        .padding()
        .background(Color.themePrimaryContainer.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
    }
}

#Preview {
    AuthBanner(collectionLabel: "Eureka")
    AuthBanner()
}
