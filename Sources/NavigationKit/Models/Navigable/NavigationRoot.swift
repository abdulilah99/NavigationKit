//
//  NavigationRoot.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 3/12/24.
//

import SwiftUI
import Observation

@Observable
@MainActor
public class NavigationRoot<Destination: Navigable>: Identifiable {
    public let destination: Destination
    public var path: [Destination]
    public let surfacePolicy: NavigationSurfacePolicy
    
    public init(
        destination: Destination,
        path: [Destination] = [],
        surfacePolicy: NavigationSurfacePolicy = .init()
    ) {
        self.destination = destination
        self.path = path
        self.surfacePolicy = surfacePolicy
    }

    public func surfaces(
        in context: NavigationPresentationContext
    ) -> NavigationSurfaces {
        surfacePolicy.surfaces(in: context)
    }
    
    var pathBinding: Binding<[Destination]> {
        .init(get: { self.path }) { newValue in
            self.path = newValue
        }
    }
    
    @ViewBuilder
    public var content: some View {
        NavigationStack(path: pathBinding) {
            destination.destination
                .modifier(destination.modifier)
                .navigationDestination(for: Destination.self) { navigable in
                    navigable.destination
                        .modifier(navigable.modifier)
                }
        }
        .environment(\.navigationPath, path)
        .environment(\.setNavigationPath, SetNavigationPathAction(action: { path in
            guard let path = path as? [Destination] else { return }
            self.path = path
        }))
    }
}
