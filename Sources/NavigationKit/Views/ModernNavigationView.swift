//
//  ModernNavigationView.swift
//  NavigationKit
//
//  Created by Abdulilah on 28/02/2025.
//

import SwiftUI

@available(iOS 18.0, macOS 15.0, tvOS 18.0, visionOS 2.0, *)
struct ModernNavigationView<Destination: Navigable>: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    let navigation: NavigationController<Destination>

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
        @Bindable var navigation = navigation

        TabView(selection: $navigation.selectedRoot) {
            ForEach(navigation.roots) { root in
                let surfaces = root.surfaces(in: surfaceContext)

                Tab(
                    value: root.destination,
                    role: root.role?.tabRole,
                    content: {
                        root.content(for: navigation)
                            #if os(iOS)
                            .background {
                                if #available(iOS 26.1, *) {
                                    NativeTabImages(
                                        pairs: navigation.roots.map {
                                            .init(
                                                icon: $0.destination.icon,
                                                selectedIcon: $0.destination.selectedIcon
                                            )
                                        },
                                        isActive: root.destination == navigation.selectedRoot
                                    )
                                }
                            }
                            #endif
                            .transformPreference(NavigationContentBoundsKey.self) {
                                if root.destination != navigation.selectedRoot { $0 = nil }
                            }
                    }
                ) {
                    Label(
                        title: { Text(root.destination.titleKey) },
                        icon: {
                            tabIcon(for: root.destination)
                        }
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
    }

    private func tabIcon(for destination: Destination) -> Image {
        #if os(iOS)
        if #available(iOS 26.1, *) {
            return destination.icon
        }
        #endif
        return destination == navigation.selectedRoot ? destination.selectedIcon : destination.icon
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
