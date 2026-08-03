//
//  NavigationPresentation.swift
//  NavigationKit
//

import Foundation
import Observation

/// One occurrence in a controller's modal presentation stack.
///
/// Presentation identity is independent from destination identity, allowing
/// the same destination value to appear more than once in the stack. Each
/// presentation also owns an independent typed route path.
@Observable
@MainActor
public final class NavigationPresentation<Destination: Navigable>:
    Identifiable,
    Equatable {
    /// The stable identity of this presentation occurrence.
    public let id: UUID

    /// The destination displayed at the base of this presentation.
    public let destination: Destination

    /// The native presentation container requested for this occurrence.
    public let style: NavigationPresentationStyle

    /// The presentation's independent route path.
    public internal(set) var path: [Destination]

    /// Creates one modal occurrence with an optional initial route path.
    public init(
        id: UUID = UUID(),
        destination: Destination,
        style: NavigationPresentationStyle,
        path: [Destination] = []
    ) {
        self.id = id
        self.destination = destination
        self.style = style
        self.path = path
    }

    /// Returns whether two values represent the same presentation occurrence.
    public nonisolated static func == (
        lhs: NavigationPresentation<Destination>,
        rhs: NavigationPresentation<Destination>
    ) -> Bool {
        lhs.id == rhs.id
    }
}
