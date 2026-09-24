//
//  LegacyNavigationView.swift
//  NavigationKit
//
//  Created by Abdulilah on 03/03/2025.
//

import SwiftUI

struct LegacyNavigationView<Destination: Navigable>: View {
    @Binding private var selection: Destination
    private let roots: [NavigationRoot<Destination>]

    init(
        roots: [NavigationRoot<Destination>],
        selection: Binding<Destination>
    ) {
        self.roots = roots
        self._selection = selection
    }

    var body: some View {
        TabView(selection: $selection) {
            ForEach(roots) { root in
                root.content
                    .transformPreference(NavigationContentBoundsKey.self) {
                        if root.destination != selection { $0 = nil }
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
