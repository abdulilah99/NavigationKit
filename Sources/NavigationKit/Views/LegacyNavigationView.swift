//
//  LegacyNavigationView.swift
//  NavigationKit
//
//  Created by Abdulilah on 03/03/2025.
//

import SwiftUI

struct LegacyNavigationView<Destination: Navigable>: View {
    let navigation: NavigationController<Destination>

    var body: some View {
        @Bindable var navigation = navigation

        TabView(selection: $navigation.selectedRoot) {
            ForEach(navigation.roots) { root in
                root.content(for: navigation)
                    .transformPreference(NavigationContentBoundsKey.self) {
                        if root.destination != navigation.selectedRoot { $0 = nil }
                    }
                    .tag(root.destination)
                    .tabItem {
                        Label(
                            title: { Text(root.destination.titleKey) },
                            icon: { root.destination.icon }
                        )
                    }
            }
        }
    }
}
