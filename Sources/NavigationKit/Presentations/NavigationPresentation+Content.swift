//
//  NavigationPresentation+Content.swift
//  NavigationKit
//

import SwiftUI

public extension NavigationPresentation {
    @ViewBuilder
    var content: some View {
        @Bindable var presentation = self

        NavigationStackHost(
            destination: destination,
            path: $presentation.path
        )
    }
}
