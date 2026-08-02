//
//  NC+PresentationNavigation.swift
//  NavigationKit
//

public extension NavigationController {
    /// Navigates inside a presentation's independent navigation path.
    ///
    /// The operation uses the same first-match reuse behavior as root
    /// navigation. A missing presentation ID is a no-op.
    func navigate(
        to destination: Destination,
        in presentationID: NavigationPresentation<Destination>.ID
    ) {
        guard let presentation = presentation(id: presentationID) else {
            return
        }

        navigatePath(&presentation.path, to: destination)
    }

    /// Removes up to `count` destinations from a presentation's path.
    ///
    /// Nonpositive counts and missing presentation IDs are no-ops.
    func navigateBack(
        _ count: Int = 1,
        in presentationID: NavigationPresentation<Destination>.ID
    ) {
        guard
            count > 0,
            let presentation = presentation(id: presentationID)
        else {
            return
        }

        guard !presentation.path.isEmpty else {
            return
        }

        presentation.path.removeLast(min(count, presentation.path.count))
    }

    /// Removes every destination from a presentation's navigation path.
    ///
    /// A missing presentation ID is a no-op.
    func returnToRoot(
        in presentationID: NavigationPresentation<Destination>.ID
    ) {
        guard
            let presentation = presentation(id: presentationID),
            !presentation.path.isEmpty
        else {
            return
        }

        presentation.path.removeAll()
    }

    /// Replaces a presentation's complete navigation path.
    ///
    /// Equal paths avoid an unnecessary observation update, and a missing
    /// presentation ID is a no-op.
    func replacePath(
        with path: [Destination],
        in presentationID: NavigationPresentation<Destination>.ID
    ) {
        guard
            let presentation = presentation(id: presentationID),
            presentation.path != path
        else {
            return
        }

        presentation.path = path
    }

    /// Reads a presentation's independent navigation path.
    ///
    /// A missing presentation ID reads as an empty path.
    subscript(
        presentation presentationID: NavigationPresentation<Destination>.ID
    ) -> [Destination] {
        presentation(id: presentationID)?.path ?? []
    }
}
