//
//  SignupViewLink.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/25/26.
//

import SwiftUI

struct SignupViewLink: View {
    var body: some View {
        NavigationLink {
            SignupView()
        } label: {
            HStack(spacing: 3) {
                Text("Don't have an account?")
                    .foregroundStyle(Color.secondary)
                
                Text("Sign up")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.themeSecondary)
            }
            .font(.footnote)
            .fontWeight(.semibold)
            .foregroundStyle(Color.themeSecondary)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

#Preview {
    SignupViewLink()
}
