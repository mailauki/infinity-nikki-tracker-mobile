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
//        ControlGroup {
//            ForEach(collections) { item in
//                Toggle(item.label, systemImage: item.icon, isOn: Binding(
//                    get: { selectedOption == item },
//                    set: { isOn in if isOn { selectedOption = item } }
//                ))
//            }
//        }
        
        Picker("Collections", selection: $selectedOption) {
            ForEach(collections) { item in
                Image(systemName: item.icon)
            }
        }
        .pickerStyle(.segmented)
        .padding()
        
        //                        ForEach(collections) { item in
        //                            VStack(spacing: 4) {
        //                                Image(systemName: item.icon)
        //                                Text(item.label)
        //                                    .font(.system(.subheadline, weight: .semibold))
        //                            }
        //                        }
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
