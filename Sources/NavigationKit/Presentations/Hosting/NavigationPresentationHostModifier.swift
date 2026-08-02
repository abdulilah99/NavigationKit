//
//  NavigationPresentationHostModifier.swift
//  NavigationKit
//

import SwiftUI

struct NavigationPresentationHostModifier<Destination: Navigable>: ViewModifier {
    let navigation: NavigationController<Destination>
    let index: Int
    var isEnabled = true

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
        content.sheet(item: presentationBinding(matching: nil)) { presentation in
            NavigationPresentationContent(
                navigation: navigation,
                presentation: presentation,
                index: index
            )
        }
        #else
        content
            .sheet(item: presentationBinding(matching: .sheet)) { presentation in
                NavigationPresentationContent(
                    navigation: navigation,
                    presentation: presentation,
                    index: index
                )
            }
            .fullScreenCover(
                item: presentationBinding(matching: .fullScreen)
            ) { presentation in
                NavigationPresentationContent(
                    navigation: navigation,
                    presentation: presentation,
                    index: index
                )
            }
        #endif
    }
}
