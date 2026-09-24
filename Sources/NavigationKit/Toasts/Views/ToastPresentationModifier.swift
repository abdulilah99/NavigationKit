//
//  ToastPresentationModifier.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 23/09/2026.
//

import SwiftUI

/// Owns surface geometry separately from the deck renderer and native modal lifecycle.
struct ToastPresentationModifier<Toast: Toastable, ToastContent: View>: ViewModifier {
    let toasts: ToastController<Toast>
    let configuration: ToastStackConfiguration
    var isEnabled = true
    @ViewBuilder var toastContent: (ToastPresentation<Toast>) -> ToastContent

    func body(content: Content) -> some View {
        content
            .overlayPreferenceValue(NavigationContentBoundsKey.self) { anchor in
                if isEnabled {
                    GeometryReader { geometry in
                        let bounds = configuration.placement.bounds(
                            in: CGRect(origin: .zero, size: geometry.size),
                            content: anchor.map { geometry[$0] }
                        )
                        ToastOverlay(toasts: toasts, configuration: configuration, toastContent: toastContent)
                            .frame(width: bounds.width, height: bounds.height)
                            .position(x: bounds.midX, y: bounds.midY)
                    }
                }
            }
            // A nested host owns its bounds; they must not reposition an ancestor host.
            .transformPreference(NavigationContentBoundsKey.self) { $0 = nil }
    }
}

extension ToastPresentationModifier where ToastContent == Toast.Content {
    init(toasts: ToastController<Toast>, configuration: ToastStackConfiguration, isEnabled: Bool = true) {
        self.init(toasts: toasts, configuration: configuration, isEnabled: isEnabled) { $0.toast.content }
    }
}

extension ToastStackConfiguration.Placement {
    func bounds(in container: CGRect, content: CGRect?) -> CGRect {
        guard self != .container, let content else { return container }
        let visibleContent = container.intersection(content)
        guard !visibleContent.isEmpty else { return container }

        switch self {
        case .automatic:
            return CGRect(
                x: visibleContent.minX,
                y: container.minY,
                width: visibleContent.width,
                height: visibleContent.maxY - container.minY
            )
        case .content:
            return visibleContent
        case .container:
            return container
        }
    }
}
