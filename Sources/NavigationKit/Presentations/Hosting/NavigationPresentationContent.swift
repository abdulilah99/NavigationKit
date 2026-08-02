//
//  NavigationPresentationContent.swift
//  NavigationKit
//

import SwiftUI

struct NavigationPresentationContent<Destination: Navigable>: View {
    let navigation: NavigationController<Destination>
    let presentation: NavigationPresentation<Destination>
    let index: Int

    @State private var isReadyForNextPresentation = false

    var body: some View {
        presentation.content
            .modifier(
                NavigationPresentationHostModifier(
                    navigation: navigation,
                    index: index + 1,
                    isEnabled: isReadyForNextPresentation
                )
            )
            .onAppear {
                isReadyForNextPresentation = true
            }
    }
}
