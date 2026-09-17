//
//  AboutView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/16/26.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Section(header: SectionHeader(title: "What is this?")) {
                    Text("A fan-made collection tracker for Infinity Nikki — see your outfits, Eureka sets, makeup, and Momo's cloaks at a glance, track your progress, and know exactly what you're still missing.")
                }
                Section(header: SectionHeader(title: "About me")) {
                    Text("I'm Julie Evans, a UX-focused developer. This tracker is a side project built with Next.js, Supabase, and MUI — born out of playing the game and wanting a clearer view of my own collection.")
                    VStack(alignment: .leading, spacing: 6) {
                        Text("• GitHub: [\("github.com/mailauki")](\("https://github.com/mailauki"))")
                        Text("• Instagram: [\("instagram.com/julieuxdev")](\("https://www.instagram.com/julieuxdev"))")
                        Text("• [\("Behind the build — Medium article")](\("https://medium.com/@julieuxdev/i-built-a-collection-tracker-for-infinity-nikki-because-the-game-wouldnt-tell-me-what-i-was-missing-95ffcf3b2109"))")
                        Text("• Contact: julie.ux.dev@gmail.com")
                    }.listStyle(.plain)
                }
                Section(header: SectionHeader(title: "Features & Pages")) {
                    Text("Browse freely without an account, or sign in to save and track your own personal collection. Filtering, sorting, and views are available either way — obtained and missing filters unlock once you're signed in.")
                    LazyHStack {} // TODO
                }
                Section(header: SectionHeader(title: "Links & Resources")) {
                    Text("This project is open source. Contributions are welcome — whether it's fixing a bug, improving the UI, or adding new data.")
                    VStack(alignment: .leading, spacing: 6) {
                        Text("• [\("GitHub Repository")](\("https://github.com/mailauki/infinity-nikki-tracker")) — the full source for this tracker, open to pull requests")
                        Text("• [\("Open an issue")](\("https://github.com/mailauki/infinity-nikki-tracker/issues")) for bugs or feature requests")
                    }.listStyle(.plain)
                }
                Section(header: SectionHeader(title: "Helpful resources")) {
                    Text("This project is open source. Contributions are welcome — whether it's fixing a bug, improving the UI, or adding new data.")
                    VStack(alignment: .leading, spacing: 6) {
                        Text("• [\("Infinity Nikki Official Website")](\("https://infinitynikki.infoldgames.com/")) — patch notes, event schedules, and official announcements")
                        Text("• [\("Infinity Nikki Wiki")](\("https://infinitynikki.fandom.com/")) — community-maintained reference for outfits, items, and quests")
                        Text("• [\("Miraland Collection")](\("https://www.miralandcollection.com/")) — browsable catalog of outfits and their pieces")
                        Text("• [\("Infinity Nikki Library")](\("https://infinitynikkilibrary.com/")) — searchable database of in-game items and sets")
                    }
                }
                Section(header: SectionHeader(title: "Roadmap")) {
                    Text("Planned features and improvements:")
                    VStack(alignment: .leading, spacing: 6) {
                        Text("• Search — quickly find sets and variants by name")
                        Text("• Outfit Pieces — tracking support for pieces not part of any outfit sets")
                        Text("• Favorites — save your favorite sets and pieces")
                        Text("• Friends — follow friends to compare collection progress")
                        Text("• Sharing — shareable links to your looks and collection")
                    }.listStyle(.plain)
                }
                Text("This is a fan-made project and is not affiliated with, endorsed by, or officially connected to Papergames or the Infinity Nikki development team. All game content, names, and assets are the property of their respective owners.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
            }
        }
    }
}

struct SectionHeader: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.title3)
            .fontDesign(.serif)
            .padding(.top, 20)
    }
}

#Preview {
    AboutView()
}
