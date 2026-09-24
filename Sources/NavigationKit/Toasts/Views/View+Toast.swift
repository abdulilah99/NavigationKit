//
//  View+Toast.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 22/09/2026.
//

import SwiftUI

public extension View {
    /// Presents custom toast content while the binding is true.
    /// Dismissal or expiry resets the binding and calls `onDismiss` once.
    /// Swipe permission updates live; expiration and placement are resolved when shown.
    /// Attach to the screen content inside native navigation/tab containers.
    func toast<Content: View>(
        isPresented: Binding<Bool>,
        expiration: ToastExpiration = .after(.seconds(4)),
        edge: VerticalEdge = .bottom,
        alignment: ToastAlignment = .center,
        swipeToDismiss: Bool = true,
        configuration: ToastStackConfiguration = .init(),
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(ToastBooleanModifier(
            isPresented: isPresented,
            expiration: expiration,
            edge: edge,
            alignment: alignment,
            swipeToDismiss: swipeToDismiss,
            configuration: configuration,
            onDismiss: onDismiss,
            toastContent: content
        ))
    }

    /// Presents an enum-defined toast while the Boolean binding is true.
    /// The toast supplies its content, expiration, placement, swipe permission, and transition.
    /// Dismissal or expiry resets the binding and calls `onDismiss` once.
    func toast<Toast: Toastable & Equatable>(
        isPresented: Binding<Bool>,
        toast: Toast,
        configuration: ToastStackConfiguration = .init(),
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        self.toast(
            item: Binding(
                get: { isPresented.wrappedValue ? toast : nil },
                set: { isPresented.wrappedValue = $0 != nil }
            ),
            configuration: configuration,
            onDismiss: onDismiss
        )
    }

    /// Presents an enum-defined toast while the optional binding is non-nil.
    /// Content changes update the occurrence without restarting its lifetime.
    /// Dismissal or expiry clears the binding and calls `onDismiss` once.
    func toast<Toast: Toastable & Equatable>(
        item: Binding<Toast?>,
        configuration: ToastStackConfiguration = .init(),
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        modifier(ToastItemModifier(item: item, configuration: configuration, onDismiss: onDismiss))
    }
}
