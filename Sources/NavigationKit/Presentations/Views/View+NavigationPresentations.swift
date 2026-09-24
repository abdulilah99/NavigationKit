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
                index: 0,
                makeOverlay: { _ in EmptyModifier() }
            )
        )
    }

    /// Presents the native modal stack and moves toast rendering to its frontmost surface.
    func navigationPresentations<Destination: Navigable, Toast: Toastable>(
        for navigation: NavigationController<Destination>,
        toasts: ToastController<Toast>,
        toastConfiguration: ToastStackConfiguration = .init()
    ) -> some View {
        modifier(
            NavigationPresentationModifier(
                navigation: navigation,
                index: 0,
                makeOverlay: { isVisible in
                    ToastPresentationModifier(toasts: toasts, configuration: toastConfiguration, isEnabled: isVisible)
                }
            )
        )
    }
}
