//
//  NC+Views.swift
//  NavigationKit
//
//  Created by Abdulilah on 03/03/2025.
//

import SwiftUI

public extension NavigationController {
    /// Creates NavigationKit's standard platform-adaptive navigation UI.
    ///
    /// Build custom navigation chrome directly from the controller's roots,
    /// selection, and navigation operations instead.
    func makeView() -> some View {
        AdaptiveNavigationView(navigation: self)
            .navigationPresentations(for: self)
    }

    /// Creates native navigation with toast decks above roots, routes, and native modals.
    func makeView<Toast: Toastable>(
        toasts: ToastController<Toast>,
        toastConfiguration: ToastStackConfiguration = .init()
    ) -> some View {
        AdaptiveNavigationView(navigation: self)
            .navigationPresentations(
                for: self,
                toasts: toasts,
                toastConfiguration: toastConfiguration
            )
    }
}
