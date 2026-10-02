//
//  NavigationRootView.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 02/10/2026.
//

import SwiftUI

struct NavigationRootView<Destination: Navigable>: View {
    let root: NavigationRoot<Destination>
    let navigation: NavigationController<Destination>

    var body: some View {
        root.content
            .environment(
                \.isNavigationDestinationVisible,
                navigation.selectedRoot == root.destination && navigation.presentations.isEmpty
            )
    }
}
