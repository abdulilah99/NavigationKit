//
//  NavigationDestinationView.swift
//  NavigationKit
//

import SwiftUI

/// Applies the rendering behavior shared by every destination placement.
struct NavigationDestinationView<Destination: Navigable>: View {
    let destination: Destination
    var isActive = true

    var body: some View {
        destination.content
            .modifier(destination.modifier)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationContentBounds(isActive: isActive)
    }
}
