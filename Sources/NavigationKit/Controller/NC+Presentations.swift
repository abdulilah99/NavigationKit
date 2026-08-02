//
//  NC+Presentations.swift
//  NavigationKit
//

public extension NavigationController {
    /// Whether the configured presentation stack has room for another layer.
    var hasPresentationCapacity: Bool {
        presentations.count < configuration.maximumPresentationDepth
    }

    /// Appends a new native presentation layer using the configured default
    /// presentation style.
    ///
    /// Returns `nil` without changing controller state when the configured
    /// maximum presentation depth has been reached.
    @discardableResult
    func present(
        _ destination: Destination,
        path: [Destination] = [],
        onDismiss: (@MainActor () -> Void)? = nil
    ) -> NavigationPresentation<Destination>? {
        present(
            destination,
            as: configuration.defaultPresentationStyle,
            path: path,
            onDismiss: onDismiss
        )
    }

    /// Appends a new native presentation layer using an explicit style.
    ///
    /// Presentations use occurrence identity, so presenting the same
    /// destination repeatedly creates distinct stack entries. Returns `nil`
    /// without changing controller state when the configured maximum
    /// presentation depth has been reached.
    @discardableResult
    func present(
        _ destination: Destination,
        as style: NavigationPresentationStyle,
        path: [Destination] = [],
        onDismiss: (@MainActor () -> Void)? = nil
    ) -> NavigationPresentation<Destination>? {
        guard hasPresentationCapacity else {
            return nil
        }

        let presentation = NavigationPresentation(
            destination: destination,
            style: style,
            path: path
        )

        storeDismissalAction(onDismiss, for: presentation.id)
        presentations.append(presentation)
        return presentation
    }

    /// Removes the top presentation, if one exists.
    func dismissPresentation() {
        guard let lastIndex = presentations.indices.last else {
            return
        }

        removePresentations(from: lastIndex)
    }

    /// Removes a presentation and every presentation above it.
    ///
    /// This mirrors native ownership: a presenting layer cannot disappear
    /// while keeping presentations that it owns alive.
    func dismissPresentation(
        id: NavigationPresentation<Destination>.ID
    ) {
        guard let index = presentations.firstIndex(where: { $0.id == id }) else {
            return
        }

        removePresentations(from: index)
    }

    /// Removes up to `count` presentations from the top of the stack.
    func dismissPresentations(count: Int) {
        guard count > 0, !presentations.isEmpty else {
            return
        }

        let removalCount = min(count, presentations.count)
        removePresentations(from: presentations.count - removalCount)
    }

    /// Removes every presentation from top to bottom.
    func dismissAllPresentations() {
        guard !presentations.isEmpty else {
            return
        }

        removePresentations(from: presentations.startIndex)
    }
}
