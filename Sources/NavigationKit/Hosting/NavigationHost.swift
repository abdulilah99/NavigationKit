//
//  NavigationHost.swift
//  NavigationKit
//

import SwiftUI

struct NavigationHost<Destination: Navigable>: View {
    let navigation: NavigationController<Destination>

    @ViewBuilder
    var body: some View {
        @Bindable var navigation = navigation

        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, visionOS 2.0, *) {
            ModernNavigationHost(
                roots: navigation.roots,
                selection: $navigation.selectedRoot
            )
        } else {
            LegacyNavigationHost(
                roots: navigation.roots,
                selection: $navigation.selectedRoot
            )
        }
    }
}
