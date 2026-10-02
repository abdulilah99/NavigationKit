//
//  NavigationDestinationView.swift
//  NavigationKit
//

import SwiftUI

/// Applies the rendering behavior shared by every destination placement.
struct NavigationDestinationView<Destination: Navigable>: View {
    let destination: Destination
    var isActive = true

    @Environment(\.isNavigationDestinationVisible) private var isVisible

    var body: some View {
        destination.content
            .modifier(destination.modifier)
            .environment(\.isNavigationDestinationVisible, isVisible && isActive)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationContentBounds(isActive: isActive)
    }
}
