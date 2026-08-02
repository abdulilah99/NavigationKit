//
//  NavigationController.swift
//  Example App
//
//  Created by Abdulilah on 23/03/2025.
//

import NavigationKit

@MainActor
func makeExampleNavigationController() -> NavigationController<Page> {
    NavigationController(
        roots: [
            NavigationRoot(
                destination: .home,
                surfacePolicy: NavigationSurfacePolicy(
                    compact: .tabBar,
                    regular: .all,
                    television: .sidebar,
                    desktop: .sidebar,
                    spatial: .all
                )
            ),
            NavigationRoot(
                destination: .library,
                surfacePolicy: NavigationSurfacePolicy(
                    compact: .tabBar,
                    regular: .sidebar,
                    television: .sidebar,
                    desktop: .sidebar,
                    spatial: .all
                )
            ),
            NavigationRoot(
                destination: .search,
                surfacePolicy: NavigationSurfacePolicy(
                    compact: .tabBar,
                    regular: .sidebar,
                    television: .sidebar,
                    desktop: .sidebar,
                    spatial: .all
                ),
                role: .search
            ),
            NavigationRoot(
                destination: .settings,
                surfacePolicy: NavigationSurfacePolicy(
                    compact: [],
                    regular: .sidebar,
                    television: .sidebar,
                    desktop: .sidebar,
                    spatial: .sidebar
                )
            ),
        ],
        selectedRoot: .home,
        configuration: NavigationConfiguration(
            defaultPresentationStyle: .sheet,
            maximumPresentationDepth: 8
        )
    )
}
