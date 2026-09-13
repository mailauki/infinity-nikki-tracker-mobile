//
//  CollectionsToggle.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/11/26.
//

import SwiftUI

struct CollectionsToggle: View {
    let collections: [CollectionItem]
    @Binding var selectedOption: CollectionItem

    var body: some View {
        Picker("Collections", selection: $selectedOption) {
            ForEach(collections) { item in
                Image(systemName: item.icon)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
}

#Preview {
    @Previewable @State var selected = CollectionItem(icon: "tshirt", label: "Outfits")
    let collections: [CollectionItem] = [
        CollectionItem(icon: "tshirt", label: "Outfits"),
        CollectionItem(icon: "theatermask.and.paintbrush", label: "Makeup"),
        CollectionItem(icon: "bubbles.and.sparkles", label: "Eureka"),
        CollectionItem(icon: "pawprint", label: "Cloaks"),
    ]
    CollectionsToggle(collections: collections, selectedOption: $selected)
}
