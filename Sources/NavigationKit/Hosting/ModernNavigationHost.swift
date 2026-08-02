//
//  ModernNavigationHost.swift
//  NavigationKit
//
//  Created by Abdulilah on 28/02/2025.
//

import SwiftUI

@available(iOS 18.0, macOS 15.0, tvOS 18.0, visionOS 2.0, *)
struct ModernNavigationHost<Destination: Navigable>: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @Binding private var selection: Destination
    private let roots: [NavigationRoot<Destination>]

    init(
        roots: [NavigationRoot<Destination>],
        selection: Binding<Destination>
    ) {
        self.roots = roots
        self._selection = selection
    }

    private var surfaceContext: NavigationSurfaceContext {
        #if os(tvOS)
        .television
        #elseif os(macOS)
        .desktop
        #elseif os(visionOS)
        .spatial
        #else
        horizontalSizeClass == .compact ? .compact : .regular
        #endif
    }

    var body: some View {
        TabView(selection: $selection) {
            ForEach(roots) { root in
                let surfaces = root.surfaces(in: surfaceContext)

                Tab(
                    value: root.destination,
                    role: root.role?.tabRole,
                    content: { root.content }
                ) {
                    Label(
                        title: { Text(root.destination.titleKey) },
                        icon: { root.destination.icon }
                    )
                }
                .tabPlacement(surfaces.contains(.tabBar) ? .automatic : .sidebarOnly)
                #if os(iOS) || os(macOS) || os(visionOS)
                .defaultVisibility(
                    surfaces.contains(.tabBar) ? .visible : .hidden,
                    for: .tabBar
                )
                #endif
                #if os(iOS) || os(visionOS)
                .defaultVisibility(
                    surfaces.contains(.sidebar) ? .visible : .hidden,
                    for: .sidebar
                )
                #endif
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, visionOS 2.0, *)
private extension NavigationRootRole {
    var tabRole: TabRole {
        switch self {
        case .search:
            .search
        }
    }
}
