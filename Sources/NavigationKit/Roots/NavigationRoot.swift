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
public final class NavigationRoot<Destination: Navigable>: Identifiable {
    public let destination: Destination
    public internal(set) var path: [Destination]
    public let surfacePolicy: NavigationSurfacePolicy
    public let role: NavigationRootRole?

    public init(
        destination: Destination,
        path: [Destination] = [],
        surfacePolicy: NavigationSurfacePolicy = .init(),
        role: NavigationRootRole? = nil
    ) {
        self.destination = destination
        self.path = path
        self.surfacePolicy = surfacePolicy
        self.role = role
    }

    public func surfaces(
        in context: NavigationSurfaceContext
    ) -> NavigationSurfaces {
        surfacePolicy.surfaces(in: context)
    }

    @ViewBuilder
    public var content: some View {
        @Bindable var root = self

        NavigationStackHost(
            destination: destination,
            path: $root.path
        )
    }
}
