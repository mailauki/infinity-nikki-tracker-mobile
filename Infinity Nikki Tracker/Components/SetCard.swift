//
//  SetCard.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/12/26.
//

import SwiftUI

// MARK: - Card Component Builder
/// A customizable Card View designed using a component-builder approach.
struct SetCard<Media: View, Content: View>: View {
    let media: Media
    let content: Content
//    let footer: Footer

    init(
        @ViewBuilder media: () -> Media,
        @ViewBuilder content: () -> Content,
//        @ViewBuilder footer: () -> Footer
    ) {
        self.media = media()
        self.content = content()
//        self.footer = footer()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            media
            content
            //            footer
        }
        .frame(width: 170)
    }
}

struct CardContent<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        content()
            .padding(10)
    }
}

// MARK: - Sub-Component Builders (Parts)
/// Reusable parts to plug into the BuilderCard
struct CardParts {
    @ViewBuilder
    static func imageMedia(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipped()
            case .failure:
                ZStack {
                    Color(.systemGroupedBackground)
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                }
            @unknown default:
                EmptyView()
            }
        }
        .aspectRatio(1/1, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(Rectangle())
        .border(Color.themeOutlineVariant, width: 1)
        .overlay(Color.themeOutline.frame(height: 2), alignment: .bottom)
        .padding(.bottom, 14)
    }
    @ViewBuilder
    static func textContent(title: String, subtitle: String, rarity: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
//                .font(.headline)
                .font(.title2)
                .fontDesign(.serif)
                .foregroundColor(Color.themeOnSurface)
            
            HStack {
                Text(subtitle)
                    .lineLimit(1)
                Spacer()
                Text("\(rarity) ★")
            }
            .font(.caption)
            .foregroundColor(Color.themeSecondary)
        }
    }
    
    @ViewBuilder
    static func actionFooter(onShare: @escaping () -> Void, onLearnMore: @escaping () -> Void) -> some View {
        HStack {
            Button(action: onShare) {
                Text("Share")
                    .font(.footnote)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            Button(action: onLearnMore) {
                Text("Learn More")
                    .font(.footnote)
                    .fontWeight(.bold)
            }
        }
        .padding([.horizontal, .bottom])
    }
}

#Preview {
    SetCard(
        media: {
            CardParts.imageMedia(url: "./Image")
        },
        content: {
            CardParts.textContent(title: "Blooming Dreams", subtitle: "elegant • season 3".uppercased(), rarity: .random(in: 0...5))
            HStack {
                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 8, height: 8)
                Text("8/8 complete")
                    .font(.caption)
            }
            .foregroundStyle(Color.themeSuccess)
            .padding(.top, 8)
        }
    )
}
