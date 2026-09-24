//
//  View+NavigationToasts.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 24/09/2026.
//

import SwiftUI

public extension View {
    /// Installs toast rendering on the navigation surfaces inside this view.
    /// Apply after `makeView()` or `.navigationPresentations(for:)` so the
    /// renderer reaches the root and each native sheet or cover through the environment.
    /// Use `.toastPresentations(for:)` to host toasts on a standalone surface.
    func navigationToasts<Toast: Toastable>(
        for toasts: ToastController<Toast>,
        configuration: ToastStackConfiguration = .init()
    ) -> some View {
        environment(\.navigationSurfaceOverlay, NavigationToastOverlay(toasts: toasts, configuration: configuration))
    }
}

private struct NavigationToastOverlay<Toast: Toastable>: NavigationSurfaceOverlay {
    let toasts: ToastController<Toast>
    let configuration: ToastStackConfiguration

    func makeView(in container: CGRect, contentBounds: CGRect?) -> AnyView {
        AnyView(
            ToastOverlay(toasts: toasts, configuration: configuration)
                .placed(in: container, contentBounds: contentBounds)
        )
    }
}
