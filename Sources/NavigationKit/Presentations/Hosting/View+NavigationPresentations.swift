//
//  View+NavigationPresentations.swift
//  NavigationKit
//

import SwiftUI

public extension View {
    /// Hosts a controller's complete native modal presentation stack.
    ///
    /// `NavigationController.makeView()` applies this automatically. Apply
    /// it once around a custom navigation host that does not use `makeView()`.
    func navigationPresentations<Destination: Navigable>(
        for navigation: NavigationController<Destination>
    ) -> some View {
        modifier(
            NavigationPresentationHostModifier(
                navigation: navigation,
                index: 0
            )
        )
    }
}
