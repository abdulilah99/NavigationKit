//
//  ToastCardView.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 22/09/2026.
//

import SwiftUI

struct ToastCardView<Toast: Toastable, ToastContent: View>: View {
    let presentation: ToastPresentation<Toast>
    let toasts: ToastController<Toast>
    let depth: Int
    let configuration: ToastStackConfiguration
    let toastContent: ToastContent

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    #if !os(tvOS)
    @Environment(\.layoutDirection) private var layoutDirection
    #endif
    @GestureState private var dragOffset: CGFloat = 0
    @State private var dismissalEdge: Edge?

    private var isFront: Bool { depth == 0 }
    private var canSwipe: Bool { isFront && presentation.toast.swipeToDismiss }
    private var direction: CGFloat { presentation.edge == .top ? -1 : 1 }

    var body: some View {
        toastContent
            .environment(toasts)
            .environment(presentation)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: presentation.edge == .top ? .top : .bottom
            )
            .clipped()
            .scaleEffect(
                max(0.1, 1 - CGFloat(depth) * configuration.scaleStep),
                anchor: presentation.edge == .top ? .top : .bottom
            )
            .offset(
                x: canSwipe ? dragOffset : 0,
                y: direction * CGFloat(depth) * configuration.stackSpacing
            )
            .allowsHitTesting(isFront)
            .disabled(!isFront)
            .accessibilityAction(.escape) {
                toasts.dismiss(id: presentation.id)
            }
            #if !os(tvOS)
            .gesture(canSwipe ? dismissalGesture : nil)
            #endif
            .transition(transition)
            .accessibilityElement(children: isFront ? .contain : .ignore)
            .accessibilityHidden(!isFront)
    }

    private var transition: AnyTransition {
        if reduceMotion { return .opacity }
        if let dismissalEdge {
            return .move(edge: dismissalEdge).combined(with: .opacity)
        }
        return presentation.toast.transition
            ?? .move(edge: presentation.edge == .top ? .top : .bottom).combined(with: .opacity)
    }

    #if !os(tvOS)
    private var dismissalGesture: some Gesture {
        DragGesture(minimumDistance: 15)
            .updating($dragOffset) { value, state, _ in
                guard canSwipe, abs(value.translation.width) > abs(value.translation.height) else { return }
                state = value.translation.width
            }
            .onEnded { value in
                guard
                    canSwipe,
                    toasts.presentations.last(where: { $0.edge == presentation.edge })?.id == presentation.id,
                    abs(value.translation.width) > abs(value.translation.height),
                    max(abs(value.translation.width), abs(value.predictedEndTranslation.width)) >= configuration.swipeThreshold
                else { return }

                if value.translation.width < 0 {
                    dismissalEdge = layoutDirection == .rightToLeft ? .trailing : .leading
                } else {
                    dismissalEdge = layoutDirection == .rightToLeft ? .leading : .trailing
                }
                toasts.dismiss(id: presentation.id)
            }
    }
    #endif
}
