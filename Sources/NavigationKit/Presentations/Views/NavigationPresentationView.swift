//
//  NavigationPresentationView.swift
//  NavigationKit
//

import SwiftUI

struct NavigationPresentationView<Destination: Navigable, Overlay: View>: View {
    let navigation: NavigationController<Destination>
    let presentation: NavigationPresentation<Destination>
    let index: Int
    let overlay: Overlay

    // Wait for this layer to enter the native hierarchy before allowing it to
    // present its child. This builds recursive stacks without eager updates.
    @State private var isReadyForNextPresentation = false

    var body: some View {
        presentation.content
            .modifier(
                NavigationPresentationModifier(
                    navigation: navigation,
                    index: index + 1,
                    overlay: overlay,
                    isEnabled: isReadyForNextPresentation
                )
            )
            .onAppear {
                isReadyForNextPresentation = true
            }
    }
}
