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
    let configuration: ToastStackConfiguration
    let onDismiss: (() -> Void)?
    @ViewBuilder let toastContent: () -> ToastContent

    @State private var presentation = ToastBindingState<ViewToast>()

    func body(content: Content) -> some View {
        content
            .modifier(
                ToastPresentationModifier(toasts: presentation.toasts, configuration: configuration) { _ in
                    toastContent()
                }
            )
            .onChange(of: isPresented, initial: true) { _, value in
                let binding = $isPresented
                let toast = value ? ViewToast(expiration: expiration, edge: edge, alignment: alignment) : nil
                presentation.synchronize(toast, resetBinding: {
                    binding.wrappedValue = false
                }, onDismiss: onDismiss)
            }
            .onDisappear { presentation.dismiss() }
    }
}

private struct ViewToast: Toastable {
    let expiration: ToastExpiration
    let edge: VerticalEdge
    let alignment: ToastAlignment
    var content: some View { EmptyView() }
}
