//
//  NC+Validation.swift
//  NavigationKit
//

extension NavigationController {
    static func validateConfiguration(
        roots: [NavigationRoot<Destination>],
        selectedRoot: Destination?,
        presentations: [NavigationPresentation<Destination>]
    ) -> Destination {
        precondition(
            !roots.isEmpty,
            "NavigationController requires at least one root."
        )
        precondition(
            hasUniqueDestinations(roots),
            "NavigationController requires every root destination to be unique."
        )

        let initialSelection = selectedRoot ?? roots[0].destination
        precondition(
            roots.contains(where: { $0.destination == initialSelection }),
            "NavigationController requires the selected root to be configured."
        )
        precondition(
            hasUniquePresentationIDs(presentations),
            "NavigationController requires every presentation ID to be unique."
        )

        return initialSelection
    }

    static func hasUniqueDestinations(
        _ roots: [NavigationRoot<Destination>]
    ) -> Bool {
        var destinations = Set<Destination>()

        return roots.allSatisfy { root in
            destinations.insert(root.destination).inserted
        }
    }

    static func hasUniquePresentationIDs(
        _ presentations: [NavigationPresentation<Destination>]
    ) -> Bool {
        var identifiers = Set<NavigationPresentation<Destination>.ID>()

        return presentations.allSatisfy { presentation in
            identifiers.insert(presentation.id).inserted
        }
    }
}
