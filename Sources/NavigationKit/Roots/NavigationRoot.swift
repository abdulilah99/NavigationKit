//
//  NavigationRoot.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 3/12/24.
//

import SwiftUI
import Observation

/// A configured top-level destination with an independent navigation path.
///
/// A root adds app-owned placement and role metadata to a destination without
/// changing the destination's identity. Root objects have stable reference
/// identity, allowing SwiftUI to preserve their paths and view state while the
/// selected root changes.
@Observable
@MainActor
public final class NavigationRoot<Destination: Navigable>: Identifiable {
    /// The destination displayed at the base of this root.
    public let destination: Destination

    /// The root's retained path, mutated through its navigation controller.
    public internal(set) var path: [Destination]

    /// The contexts and native navigation surfaces where the root may appear.
    public let surfacePolicy: NavigationSurfacePolicy

    /// An optional semantic role used by supported native navigation views.
    public let role: NavigationRootRole?

    /// Creates a configured root and its initial independent path.
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

    /// Returns the native navigation surfaces requested for a context.
    public func surfaces(
        in context: NavigationSurfaceContext
    ) -> NavigationSurfaces {
        surfacePolicy.surfaces(in: context)
    }

    /// The root destination wrapped in its independent navigation stack.
    @ViewBuilder
    public var content: some View {
        @Bindable var root = self

        NavigationStackView(
            destination: destination,
            path: $root.path
        )
    }
}
