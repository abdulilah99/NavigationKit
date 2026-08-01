//
//  NavigationController.swift
//  Serotonin
//
//  Created by Abdulilah on 26/02/2025.
//

import Observation

@Observable
@MainActor
public final class NavigationController<Destination: Navigable> {
    public private(set) var selectedRoot: Destination
    public let roots: [NavigationRoot<Destination>]

    public init(
        roots: [NavigationRoot<Destination>],
        selectedRoot: Destination? = nil
    ) {
        precondition(!roots.isEmpty, "NavigationController requires at least one root.")
        precondition(
            Self.hasUniqueDestinations(roots),
            "NavigationController requires every root destination to be unique."
        )

        let initialSelection = selectedRoot ?? roots[0].destination
        precondition(
            roots.contains(where: { $0.destination == initialSelection }),
            "NavigationController requires the selected root to be configured."
        )

        self.roots = roots
        self.selectedRoot = initialSelection
    }

    func root(for destination: Destination) -> NavigationRoot<Destination>? {
        roots.first(where: { $0.destination == destination })
    }

    @discardableResult
    func updateSelection(to root: Destination) -> Bool {
        guard self.root(for: root) != nil else {
            return false
        }

        selectedRoot = root
        return true
    }

    static func hasUniqueDestinations(
        _ roots: [NavigationRoot<Destination>]
    ) -> Bool {
        var destinations = Set<Destination>()

        return roots.allSatisfy { root in
            destinations.insert(root.destination).inserted
        }
    }
}
