//
//  AuthView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/11/26.
//

import SwiftUI

struct AuthView: View {
    var body: some View {
        VStack {
            // Top Image
            Image("Image")
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 356, height: 480)
                .clipped()
                .overlay(alignment: .topLeading) {
                    // Hero
                    VStack(alignment: .leading, spacing: 11) {
                        // App Icon
                        RoundedRectangle(cornerRadius: 17, style: .continuous)
                            .fill(.accent)
                            .frame(width: 72, height: 72)
                            .clipped()
                            .shadow(color: Color(.sRGBLinear, red: 0/255, green: 0/255, blue: 0/255).opacity(0.12), radius: 8, x: 0, y: 4)
                            .overlay {
                                Image(systemName: "sparkle")
                                    .imageScale(.large)
                                    .font(.system(size: 31, weight: .regular, design: .default)).foregroundStyle(.white)
                            }
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Infinity Nikki Tracker")
                                .font(.system(.largeTitle, weight: .medium))
                            Text("Track your collection from your favorite cozy open-world game.")
                                .font(.system(.headline, weight: .medium))
                                .frame(width: 190, alignment: .leading)
                                .clipped()
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding()
                    .padding(.top, 42)
                }
                .overlay(alignment: .bottom) {
                    // Planes Visual
                    HStack {
                        Spacer()
                        ForEach(0..<5) { _ in // Replace with your data model here
                            Image(systemName: "airplane.departure")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(Color(.quaternaryLabel))
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .padding()
                    .background {
                        Rectangle()
                            .fill(.clear)
                            .background(Material.thin)
                            .mask {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                            }
                    }
                    .padding()
                }
                .mask {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                }
                .padding()
                .padding(.top, 40)
                .shadow(color: Color(.sRGBLinear, red: 0/255, green: 0/255, blue: 0/255).opacity(0.15), radius: 18, x: 0, y: 14)
            VStack(spacing: 10) {
                ForEach(0..<3) { _ in // Replace with your data model here
                    // Email
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: "envelope.fill")
                            .imageScale(.medium)
                        Text("Continue with Email")
                    }
                    .font(.system(.body, weight: .medium))
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .foregroundStyle(.orange)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(.clear.opacity(0.25), lineWidth: 0)
                            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(.yellow.opacity(0.15)))
                    }
                }
                Text("Already booked a ticket?")
                    .padding(.top)
                    .foregroundStyle(Color(.tertiaryLabel))
                    .font(.subheadline)
            }
            .padding(.horizontal)
            Spacer()
        }
    }
}

#Preview {
    AuthView()
}
