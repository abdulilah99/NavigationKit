//
//  ToastBindingModifier.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 22/09/2026.
//

import SwiftUI

struct ToastItemModifier<Toast: Toastable & Equatable>: ViewModifier {
    @Binding var item: Toast?
    let configuration: ToastStackConfiguration
    let onDismiss: (() -> Void)?

    @State private var presentation: ToastBindingState<Toast>

    init(item: Binding<Toast?>, configuration: ToastStackConfiguration, onDismiss: (() -> Void)?) {
        _item = item
        self.configuration = configuration
        self.onDismiss = onDismiss
        _presentation = State(initialValue: ToastBindingState<Toast>())
    }

    func body(content: Content) -> some View {
        content
            .toastPresentations(for: presentation.toasts, configuration: configuration)
            .onChange(of: item, initial: true) { _, value in
                let binding = $item
                presentation.synchronize(value, resetBinding: {
                    // A pending replacement must survive an older occurrence's expiry.
                    if binding.wrappedValue == value { binding.wrappedValue = nil }
                }, onDismiss: onDismiss)
            }
            .onDisappear { presentation.dismiss() }
    }
}

struct ToastBooleanModifier<ToastContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let expiration: ToastExpiration
    let edge: VerticalEdge
    let alignment: ToastAlignment
    let swipeToDismiss: Bool
    let configuration: ToastStackConfiguration
    let onDismiss: (() -> Void)?
    @ViewBuilder let toastContent: () -> ToastContent

    @State private var presentation = ToastBindingState<ViewToast>()

    func body(content: Content) -> some View {
        let toast = isPresented ? ViewToast(
            expiration: expiration,
            edge: edge,
            alignment: alignment,
            swipeToDismiss: swipeToDismiss
        ) : nil

        content
            .modifier(
                ToastPresentationModifier(toasts: presentation.toasts, configuration: configuration) { _ in
                    toastContent()
                }
            )
            .onChange(of: toast, initial: true) { _, value in
                let binding = $isPresented
                presentation.synchronize(value, resetBinding: {
                    binding.wrappedValue = false
                }, onDismiss: onDismiss)
            }
            .onDisappear { presentation.dismiss() }
    }
}

private struct ViewToast: Toastable, Equatable {
    let expiration: ToastExpiration
    let edge: VerticalEdge
    let alignment: ToastAlignment
    let swipeToDismiss: Bool
    var content: some View { EmptyView() }
}
