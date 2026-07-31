//
//  TabNavigationView.swift
//  Serotonin
//
//  Created by Abdulilah on 28/02/2025.
//

import SwiftUI

@available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
struct TabNavigationView<Destination: Navigable>: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
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

    private var presentationContext: NavigationPresentationContext {
        #if os(tvOS)
        .television
        #elseif os(macOS)
        .desktop
        #elseif os(visionOS)
        .spatial
        #else
        horizontalSizeClass == .compact ? .compact : .expanded
        #endif
    }
    
    public var body: some View {
        TabView(selection: $selection) {
            ForEach(roots) { root in
                let surfaces = root.surfaces(in: presentationContext)

                Tab(
                    value: root.destination,
                    role: root.destination.role,
                    content: { root.content }
                ) {
                    Label(
                        title: { Text(root.destination.titleKey) },
                        icon: { root.destination.image }
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
        .environment(\.serotoninNamespace, namespace)
    }
}
