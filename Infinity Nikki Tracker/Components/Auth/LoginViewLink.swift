//
//  LoginViewLink.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/25/26.
//

import SwiftUI

struct LoginViewLink: View {
    var body: some View {
        NavigationLink {
            LoginView()
        } label: {
            HStack(spacing: 3) {
                Text("Already have an account?")
                    .foregroundStyle(Color.secondary)
                
                Text("Login")
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
    LoginViewLink()
}
