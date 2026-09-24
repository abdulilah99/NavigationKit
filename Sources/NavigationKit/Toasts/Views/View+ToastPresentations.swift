//
//  View+ToastPresentations.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 22/09/2026.
//

import SwiftUI

public extension View {
    /// Overlays top and bottom toast decks on this view's surface.
    /// Install inside app-owned sheets as well when they need to display toasts.
    /// Use `.navigationToasts(for:)` for automatic hosting across NavigationKit surfaces.
    func toastPresentations<Toast: Toastable>(
        for toasts: ToastController<Toast>,
        configuration: ToastStackConfiguration = .init()
    ) -> some View {
        modifier(ToastPresentationModifier(toasts: toasts, configuration: configuration))
    }
}
