//
//  EurekaSetRow.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/25/26.
//

import SwiftUI

struct EurekaSetRow: View {
    var eurekaSet: EurekaSet
    
    var body: some View {
        CardView(item: eurekaSet, layout: .row)
    }
}
