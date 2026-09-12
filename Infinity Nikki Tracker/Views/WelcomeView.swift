//
//  WelcomeView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 1/28/26.
//

import SwiftUI

let gradientColors: [Color] = [
    .themeSurface,
    .themePrimaryContainer
]

struct WelcomeView: View {
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .frame(width: 150, height: 150)
                    .foregroundStyle(.tint)
                
                Image(systemName: "sparkle")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)
            }
            
            Text("Infinity Nikki Tracker")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top)
                .multilineTextAlignment(.center)
            
            
            Text("Track your collection from your favorite cozy open-world game")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary.opacity(0.75))
                .frame(maxWidth: 300)
            
            Spacer()
            
            NavigationLink(destination: LoginView()) {
                Text("Get Started")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.themeOnSecondary)
                    .padding()
                    .padding(.horizontal, 40)
                    .background(Color.themeSecondary)
                    .cornerRadius(.infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 120)
        .padding(.bottom, 80)
        .background(Gradient(colors: gradientColors))
    }
}

#Preview {
    WelcomeView()
}
