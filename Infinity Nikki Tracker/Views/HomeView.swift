//
//  HomeView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/14/26.
//

import SwiftUI

enum CollectionKind: Hashable, CaseIterable, Identifiable {
    case outfits, eureka, makeup, cloaks

    var id: Self { self }

    var title: String {
        switch self {
        case .outfits: "Outfits"
        case .eureka: "Eureka"
        case .makeup: "Makeup"
        case .cloaks: "Momo's Cloaks"
        }
    }

    var image: String {
        switch self {
        case .outfits: "outfits"
        case .eureka: "eureka"
        case .makeup: "makeup"
        case .cloaks: "momo-cloak"
        }
    }
}

enum DetailSelection: Hashable {
    case outfit(OutfitSet)
    case eureka(EurekaSet)
    case makeup(MakeupSet)
}

struct HomeView: View {
    @Binding var selectedTab: AppTab

    @State private var selectedCollection: CollectionKind?
    @State private var selectedOutfit: OutfitSet?
    @State private var selectedEureka: EurekaSet?
    @State private var selectedMakeup: MakeupSet?
    @State private var preferredCompactColumn = NavigationSplitViewColumn.detail

    // A single, always-present item binding for navigationDestination(item:). Two separate
    // modifiers that come and go with the switch below get torn down along with their case,
    // orphaning whatever they'd pushed instead of popping it — this stays mounted regardless
    // of which collection is selected, so switching collections reliably pops stale detail.
    private var selectedDetail: Binding<DetailSelection?> {
        Binding(
            get: {
                if let selectedOutfit { return .outfit(selectedOutfit) }
                if let selectedEureka { return .eureka(selectedEureka) }
                if let selectedMakeup { return .makeup(selectedMakeup) }
                return nil
            },
            set: { newValue in
                switch newValue {
                case .outfit(let outfit):
                    selectedOutfit = outfit
                    selectedEureka = nil
                    selectedMakeup = nil
                case .eureka(let eureka):
                    selectedEureka = eureka
                    selectedOutfit = nil
                    selectedMakeup = nil
                case .makeup(let makeup):
                    selectedMakeup = makeup
                    selectedOutfit = nil
                    selectedEureka = nil
                case nil:
                    selectedOutfit = nil
                    selectedEureka = nil
                    selectedMakeup = nil
                }
            }
        )
    }

    private var collectionSelection: Binding<CollectionKind?> {
        Binding(
            get: { selectedCollection },
            set: { newValue in
                selectedOutfit = nil
                selectedEureka = nil
                selectedMakeup = nil
                selectedCollection = newValue
            }
        )
    }

    var body: some View {
        NavigationSplitView(preferredCompactColumn: $preferredCompactColumn) {
            List(selection: collectionSelection) {
                Section {
                    ForEach(CollectionKind.allCases) { kind in
                        NavigationLink(value: kind) {
                            CollectionRow(title: kind.title, image: kind.image)
                        }
                    }
                }
                .foregroundColor(Color.themeOnSurface)
                .listRowBackground(Color.themeSurfaceContainerLowest)
            }
            .scrollContentBackground(.hidden)
            .background(Color.themeSurface)
            .navigationTitle("Collections")
        } content: {
            Group {
                switch selectedCollection {
                case .outfits:
                    OutfitsView(selection: $selectedOutfit)
                case .eureka:
                    EurekaView(selection: $selectedEureka)
                case .makeup:
                    MakeupView(selection: $selectedMakeup)
                case .cloaks:
                    CloaksView()
                case nil:
                    Text("Select a collection")
                }
            }
            .navigationDestination(item: selectedDetail) { detail in
                switch detail {
                case .outfit(let outfit):
                    OutfitDetail(outfitSet: outfit)
                case .eureka(let eureka):
                    EurekaDetail(eurekaSet: eureka)
                case .makeup(let makeup):
                    MakeupDetail(makeupSet: makeup)
                }
            }
        } detail: {
            Hero(selectedTab: $selectedTab)
        }
    }
}

struct CollectionRow: View {
    var title: String
    var image: String

    var body: some View {
        HStack(spacing: 10) {
            Image(image)
                .resizable()
                .frame(width: 40, height: 40)
            Text(title)
        }
    }
}

struct Hero: View {
    @Binding var selectedTab: AppTab

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
                    .frame(height: 240)
            }
            VStack(spacing: 10) {
                Spacer()
                VStack(spacing: 2) {
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

                CTAButtons(selectedTab: $selectedTab)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 400)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

struct CTAButtons: View {
    @Environment(AuthManager.self) private var authManager
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack {
            if authManager.isAuthenticated {
                Button {
                    selectedTab = .profile
                } label: {
                    Text("My Collection")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(Color.themeInverseSurface)
                .foregroundColor(Color.themeOnInverseSurface)
            } else {
                NavigationLink {
                    SignupView()
                } label: {
                    Text("Sign up")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(Color.themeInverseSurface)
                .foregroundColor(Color.themeOnInverseSurface)
            }
            Button {
                selectedTab = .seasons
            } label: {
                Text("Seasons")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .tint(Color.themeInverseSurface)
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
        .environment(AuthManager())
}
