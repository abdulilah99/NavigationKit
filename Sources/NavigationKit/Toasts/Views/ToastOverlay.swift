//
//  ToastOverlay.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 22/09/2026.
//

import SwiftUI

struct ToastOverlay<Toast: Toastable, ToastContent: View>: View {
    let toasts: ToastController<Toast>
    let configuration: ToastStackConfiguration
    @ViewBuilder var toastContent: (ToastPresentation<Toast>) -> ToastContent

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let top = toasts.presentations.filter { $0.edge == .top }
        let bottom = toasts.presentations.filter { $0.edge == .bottom }

        VStack(spacing: 12) {
            ToastStackView(presentations: top, toasts: toasts, edge: .top, configuration: configuration, toastContent: toastContent)
                .allowsHitTesting(!top.isEmpty)
            Spacer(minLength: 0)
                .allowsHitTesting(false)
            ToastStackView(presentations: bottom, toasts: toasts, edge: .bottom, configuration: configuration, toastContent: toastContent)
                .allowsHitTesting(!bottom.isEmpty)
        }
        .padding(configuration.insets)
        .allowsHitTesting(!toasts.presentations.isEmpty)
        .animation(animation, value: top.map(\.id))
        .animation(animation, value: bottom.map(\.id))
        .animation(animation, value: top.last?.alignment)
        .animation(animation, value: bottom.last?.alignment)
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .active { toasts.removeExpiredToasts() }
        }
    }

    private var animation: Animation? {
        reduceMotion ? .easeOut(duration: 0.15) : configuration.animation
    }
}
