//
//  LegacyNavigationView.swift
//  NavigationKit
//
//  Created by Abdulilah on 03/03/2025.
//

import SwiftUI

struct LegacyNavigationView<Destination: Navigable>: View {
    @Namespace private var namespace
    
    @Binding private var selection: Destination?
    private var roots: [NavigationRoot<Destination>]
    
    init(
        roots: [NavigationRoot<Destination>],
        selection: Binding<Destination?>
    ) {
        self.roots = roots
        self._selection = selection
    }
    
    public var body: some View {
        TabView(selection: $selection) {
            ForEach(roots) { root in
                root.content
                    .tag(root.destination)
                    .tabItem {
                        Label(
                            title: { Text(root.destination.titleKey) },
                            icon: { root.destination.image }
                        )
                    }
            }
        }
        .environment(\.serotoninNamespace, namespace)
    }
}
