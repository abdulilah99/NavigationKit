//
//  AdaptiveNavigationView.swift
//  NavigationKit
//

import SwiftUI

struct AdaptiveNavigationView<Destination: Navigable>: View {
    let navigation: NavigationController<Destination>

    @ViewBuilder
    var body: some View {
        @Bindable var navigation = navigation

        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, visionOS 2.0, *) {
            ModernNavigationView(
                roots: navigation.roots,
                selection: $navigation.selectedRoot
            )
        } else {
            LegacyNavigationView(
                roots: navigation.roots,
                selection: $navigation.selectedRoot
            )
        }
    }
}
