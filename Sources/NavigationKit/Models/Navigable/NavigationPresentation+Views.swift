//
//  NavigationPresentation+Views.swift
//  NavigationKit
//

import SwiftUI

public extension NavigationPresentation {
    @ViewBuilder
    var content: some View {
        @Bindable var presentation = self

        NavigationStack(path: $presentation.path) {
            destination.destination
                .modifier(destination.modifier)
                .navigationDestination(for: Destination.self) { destination in
                    destination.destination
                        .modifier(destination.modifier)
                }
        }
    }
}
