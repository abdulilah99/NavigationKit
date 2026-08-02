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
                    expanded: .all,
                    television: .sidebar,
                    desktop: .sidebar,
                    spatial: .all
                )
            ),
            NavigationRoot(
                destination: .library,
                surfacePolicy: NavigationSurfacePolicy(
                    compact: .tabBar,
                    expanded: .sidebar,
                    television: .sidebar,
                    desktop: .sidebar,
                    spatial: .all
                )
            ),
            NavigationRoot(
                destination: .search,
                surfacePolicy: NavigationSurfacePolicy(
                    compact: .tabBar,
                    expanded: .sidebar,
                    television: .sidebar,
                    desktop: .sidebar,
                    spatial: .all
                )
            ),
            NavigationRoot(
                destination: .settings,
                surfacePolicy: NavigationSurfacePolicy(
                    compact: [],
                    expanded: .sidebar,
                    television: .sidebar,
                    desktop: .sidebar,
                    spatial: .sidebar
                )
            ),
        ],
        selectedRoot: .home,
        configuration: NavigationControllerConfiguration(
            defaultPresentationStyle: .sheet,
            maximumPresentationDepth: 8
        )
    )
}
