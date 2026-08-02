//
//  NavigationController.swift
//  NavigationKit
//
//  Created by Abdulilah on 26/02/2025.
//

import Observation

@Observable
@MainActor
public final class NavigationController<Destination: Navigable> {
    public let roots: [NavigationRoot<Destination>]
    public internal(set) var selectedRoot: Destination
    public internal(set) var presentations: [NavigationPresentation<Destination>]

    @ObservationIgnored
    private var presentationDismissalActions: [
        NavigationPresentation<Destination>.ID: @MainActor () -> Void
    ] = [:]

    public init(
        roots: [NavigationRoot<Destination>],
        selectedRoot: Destination? = nil,
        presentations: [NavigationPresentation<Destination>] = []
    ) {
        let initialSelection = Self.validateConfiguration(
            roots: roots,
            selectedRoot: selectedRoot,
            presentations: presentations
        )

        self.roots = roots
        self.selectedRoot = initialSelection
        self.presentations = presentations
    }

    func storeDismissalAction(
        _ action: (@MainActor () -> Void)?,
        for id: NavigationPresentation<Destination>.ID
    ) {
        presentationDismissalActions[id] = action
    }

    func takeDismissalAction(
        for id: NavigationPresentation<Destination>.ID
    ) -> (@MainActor () -> Void)? {
        presentationDismissalActions.removeValue(forKey: id)
    }
}
