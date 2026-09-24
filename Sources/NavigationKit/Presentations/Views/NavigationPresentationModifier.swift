//
//  NavigationPresentationModifier.swift
//  NavigationKit
//

import SwiftUI

struct NavigationPresentationModifier<Destination: Navigable, Overlay: ViewModifier>: ViewModifier {
    let navigation: NavigationController<Destination>
    let index: Int
    let makeOverlay: (Bool) -> Overlay
    var isEnabled = true

    @State private var visibleChildID: NavigationPresentation<Destination>.ID?

    private var presentationID: NavigationPresentation<Destination>.ID? {
        guard isEnabled else {
            return nil
        }

        return navigation.presentation(at: index)?.id
    }

    /// Captures occurrence identity so a delayed native dismissal cannot
    /// accidentally remove a replacement that later occupies this index.
    private func presentationBinding(
        matching style: NavigationPresentationStyle?
    ) -> Binding<NavigationPresentation<Destination>?> {
        let expectedID = presentationID

        return Binding(
            get: {
                guard
                    let expectedID,
                    let presentation = navigation.presentation(at: index),
                    presentation.id == expectedID,
                    style == nil || presentation.style == style
                else {
                    return nil
                }

                return presentation
            },
            set: { newValue in
                guard newValue == nil, let expectedID else {
                    return
                }

                navigation.dismissPresentation(id: expectedID)
            }
        )
    }

    func body(content: Content) -> some View {
        #if os(macOS) || os(visionOS)
        // These platforms map both semantic styles to their native sheet.
        content
            .modifier(makeOverlay(visibleChildID == nil))
            .sheet(item: presentationBinding(matching: nil)) { presentation in
                presentationView(presentation)
            }
        #else
        content
            .modifier(makeOverlay(visibleChildID == nil))
            .sheet(item: presentationBinding(matching: .sheet)) { presentation in
                presentationView(presentation)
            }
            .fullScreenCover(
                item: presentationBinding(matching: .fullScreen)
            ) { presentation in
                presentationView(presentation)
            }
        #endif
    }

    private func presentationView(_ presentation: NavigationPresentation<Destination>) -> some View {
        NavigationPresentationView(
            navigation: navigation,
            presentation: presentation,
            index: index,
            makeOverlay: makeOverlay
        )
        .onAppear {
            visibleChildID = presentation.id
        }
        .onDisappear {
            // A late dismissal must not expose the parent beneath a replacement.
            if visibleChildID == presentation.id { visibleChildID = nil }
        }
    }
}
