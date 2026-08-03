//
//  NavigationController.swift
//  NavigationKit
//
//  Created by Abdulilah on 26/02/2025.
//

import Observation

/// The observable source of truth for an application's navigation state.
///
/// A controller owns a fixed catalog of roots, each root's independent path,
/// the selected root, modal presentation occurrences, and the commands that
/// mutate them. Use `makeView()` for NavigationKit's native view or read this
/// state and call its commands from a custom navigation view.
@Observable
@MainActor
public final class NavigationController<Destination: Navigable> {
    /// The fixed catalog of configured navigation roots.
    public let roots: [NavigationRoot<Destination>]

    /// The destination of the currently selected root.
    public internal(set) var selectedRoot: Destination

    /// The active modal presentation stack, ordered from bottom to top.
    public internal(set) var presentations: [NavigationPresentation<Destination>]

    /// Controller-wide policies used by future navigation operations.
    public var configuration: NavigationConfiguration

    @ObservationIgnored
    private var presentationDismissalActions: [
        NavigationPresentation<Destination>.ID: @MainActor () -> Void
    ] = [:]

    /// Creates a controller with fixed roots and optional initial state.
    ///
    /// When `selectedRoot` is omitted, the first configured root is selected.
    /// Initialization requires at least one root, unique root destinations, a
    /// configured selection, unique presentation IDs, and an initial modal
    /// stack no deeper than the configured maximum.
    public init(
        roots: [NavigationRoot<Destination>],
        selectedRoot: Destination? = nil,
        presentations: [NavigationPresentation<Destination>] = [],
        configuration: NavigationConfiguration = .default
    ) {
        let initialSelection = Self.validateConfiguration(
            roots: roots,
            selectedRoot: selectedRoot,
            presentations: presentations,
            configuration: configuration
        )

        self.roots = roots
        self.selectedRoot = initialSelection
        self.presentations = presentations
        self.configuration = configuration
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
