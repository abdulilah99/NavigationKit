//
//  NavigationPresentation+Content.swift
//  NavigationKit
//

import SwiftUI

public extension NavigationPresentation {
    /// The presented destination wrapped in its independent navigation stack.
    @ViewBuilder
    var content: some View {
        @Bindable var presentation = self

        NavigationStackView(
            destination: destination,
            path: $presentation.path
        )
    }
}
