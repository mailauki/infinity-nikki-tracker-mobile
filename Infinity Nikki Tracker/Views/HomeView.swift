//
//  HomeView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/14/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                Hero()
                CTAButtons()
            }
        }
    }
}
    
struct Hero: View {
    var body: some View {
        ZStack {
            Image("Image")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                )
                .clipped()
            VStack {
                Spacer()
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.themeSurface,
                                Color.themeSurface.opacity(0.5),
                                .clear
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(height: 200)
            }
            VStack {
                Spacer()
                Text("Infinity Nikki Tracker")
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontDesign(.serif)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.themeOnSurface)
                
                Text("Track your collection from your favorite cozy open-world game")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.themeOnSurfaceVariant)
                    .frame(maxWidth: 240)
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 400)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

struct CTAButtons: View {
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        HStack {
            if authManager.isAuthenticated {
                NavigationLink {
                    ProfileView()
                } label: {
                    Text("My Collection")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(Color.themeInverseSurface)
            } else {
                NavigationLink {
                    SignupView()
                } label: {
                    Text("Sign up")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(Color.themeInverseSurface)
            }
            NavigationLink {
                Text("Seasons")
            } label: {
                Text("Browse Seasons")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .tint(Color.themeInverseSurface)
        }
    }
}

#Preview {
    HomeView()
        .environment(AuthManager())
}
