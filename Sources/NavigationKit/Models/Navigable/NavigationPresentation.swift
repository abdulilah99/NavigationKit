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
public final class NavigationPresentation<Destination: Navigable>: Identifiable,
    Equatable {
    public let id: UUID
    public let destination: Destination
    public let style: NavigationPresentationStyle
    public var path: [Destination]

    public init(
        id: UUID = UUID(),
        destination: Destination,
        style: NavigationPresentationStyle = .sheet,
        path: [Destination] = []
    ) {
        self.id = id
        self.destination = destination
        self.style = style
        self.path = path
    }

    public nonisolated static func == (
        lhs: NavigationPresentation<Destination>,
        rhs: NavigationPresentation<Destination>
    ) -> Bool {
        lhs.id == rhs.id
    }
}
