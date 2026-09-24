//
//  View+NavigationPresentations.swift
//  NavigationKit
//

import SwiftUI

public extension View {
    /// Presents a controller's complete native modal stack.
    ///
    /// `NavigationController.makeView()` applies this automatically. Apply
    /// it once around a custom navigation view that does not use `makeView()`.
    func navigationPresentations<Destination: Navigable>(
        for navigation: NavigationController<Destination>
    ) -> some View {
        modifier(
            NavigationPresentationModifier(
                navigation: navigation,
                index: 0
            )
        )
    }
}
