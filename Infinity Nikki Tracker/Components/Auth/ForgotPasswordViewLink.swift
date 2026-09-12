//
//  ForgotPasswordViewLink.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/25/26.
//

import SwiftUI

struct ForgotPasswordViewLink: View {
    var body: some View {
        NavigationLink("Forgot your password?") {
            ForgotPasswordView()
        }
        .font(.footnote)
        .fontWeight(.semibold)
        .foregroundStyle(Color.themeSecondary)
        .padding(.top, 8)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

#Preview {
    ForgotPasswordViewLink()
}
