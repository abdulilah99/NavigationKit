//
//  NavigationDestinationView.swift
//  NavigationKit
//

import SwiftUI

/// Applies the rendering behavior shared by every destination placement.
struct NavigationDestinationView<Destination: Navigable>: View {
    let destination: Destination

    var body: some View {
        destination.content
            .modifier(destination.modifier)
    }
}
