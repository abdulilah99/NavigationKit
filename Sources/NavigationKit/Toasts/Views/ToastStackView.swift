//
//  ToastStackView.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 22/09/2026.
//

import SwiftUI

struct ToastStackView<Toast: Toastable>: View {
    let presentations: [ToastPresentation<Toast>]
    let toasts: ToastController<Toast>
    let edge: VerticalEdge
    let configuration: ToastStackConfiguration

    var body: some View {
        let visible = Array(presentations.suffix(configuration.maximumVisibleToasts))

        ToastStackLayout(
            edge: edge,
            maximumWidth: configuration.maximumWidth,
            spacing: configuration.stackSpacing
        ) {
            ForEach(Array(visible.enumerated()), id: \.element.id) { index, presentation in
                ToastCardView(
                    presentation: presentation,
                    toasts: toasts,
                    depth: visible.count - index - 1,
                    configuration: configuration
                )
                .zIndex(Double(index))
            }
        }
        .frame(maxWidth: .infinity, alignment: alignment)
    }

    private var alignment: Alignment {
        switch presentations.last?.alignment ?? .center {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }
}
