//
//  CardView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/13/26.
//

import SwiftUI

struct CardView: View {
    let eurekaSet: EurekaSet
    // TODO: add variants for OutfitSet and others
    // TODO: add variants for sets vs pieces

    private var total: Int { eurekaSet.eurekaVariants.count }
    private var obtained: Int { eurekaSet.eurekaVariants.filter { $0.obtained == true }.count }
    // obtained is nil on all variants until applyObtained runs (requires a logged-in user)
    private var hasUserData: Bool { eurekaSet.eurekaVariants.contains { $0.obtained != nil } }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CardMediaView(url: eurekaSet.imageURL ?? "", square: true)
            CardContentView(title: eurekaSet.title, rarity: eurekaSet.rarity ?? 0, style: eurekaSet.style ?? "", label: eurekaSet.label ?? "", obtained: obtained, total: total, showProgress: hasUserData)
        }
        .overlay(alignment: .topTrailing) {
            if hasUserData {
                CheckToggle(isChecked: obtained == total && total > 0)
                    .offset(x: -10, y: 10)
            }
        }
    }
}

struct CardMediaView: View {
    let url: String
    let square: Bool
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                ZStack {
                    Color(.systemGray6)
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
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
        .aspectRatio(square ? 1/1 : 3/4, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(Rectangle())
        .border(Color.themeOutlineVariant, width: 1)
        .overlay(Color.themeOutline.frame(height: 2), alignment: .bottom)
        .padding(.bottom, 14)
    }
}

struct CardContentView: View {
    let title: String
    let rarity: Int
    let style: String
    let label: String
    let obtained: Int
    let total: Int
    let showProgress: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title2)
                .fontDesign(.serif)
                .foregroundColor(Color.themeOnSurface)
                .lineLimit(1)

            HStack {
                HStack(spacing: 2) {
                    Text(label.uppercased())
                    Text("•")
                    Text(style.uppercased())
                }
                Spacer()
                Text("\(rarity) ★")
            }
            .font(.caption)
            .foregroundColor(Color.themeSecondary)

            if showProgress {
                CompletionProgress(obtained: obtained, total: total)
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack {
            CardView(eurekaSet: SeedData.eurekaSetComplete)
            CardView(eurekaSet: SeedData.eurekaSetPartial)
            CardView(eurekaSet: SeedData.eurekaSetEmpty)
        }
        .padding()
    }
}
