//
//  ToastPresentationModifier.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 23/09/2026.
//

import SwiftUI

/// Hosts toast content on one standalone surface.
struct ToastPresentationModifier<Toast: Toastable, ToastContent: View>: ViewModifier {
    let toasts: ToastController<Toast>
    let configuration: ToastStackConfiguration
    @ViewBuilder var toastContent: (ToastPresentation<Toast>) -> ToastContent

    func body(content: Content) -> some View {
        content
            .navigationSurfaceOverlay { container, contentBounds in
                ToastOverlay(toasts: toasts, configuration: configuration, toastContent: toastContent)
                    .placed(in: container, contentBounds: contentBounds)
            }
            // This host owns its bounds; they must not reposition an ancestor host.
            .transformPreference(NavigationContentBoundsKey.self) { $0 = nil }
    }
}

extension ToastPresentationModifier where ToastContent == Toast.Content {
    init(toasts: ToastController<Toast>, configuration: ToastStackConfiguration) {
        self.init(toasts: toasts, configuration: configuration) { $0.toast.content }
    }
}
