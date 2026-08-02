//
//  NC+Navigation.swift
//  NavigationKit
//
//  Created by Abdulilah on 03/03/2025.
//

public extension NavigationController {
    func select(root: Destination) {
        updateSelection(to: root)
    }

    /// Navigates to a destination on the selected or specified root.
    ///
    /// An absent destination is appended. When the destination already exists,
    /// everything after its first occurrence is removed. Specifying a root also
    /// selects it. An unconfigured root is a no-op.
    func navigate(
        to destination: Destination,
        on root: Destination? = nil
    ) {
        let targetRoot = root ?? selectedRoot

        guard let configuredRoot = self.root(for: targetRoot) else {
            return
        }

        navigatePath(&configuredRoot.path, to: destination)
        updateSelection(to: targetRoot)
    }

    /// Removes up to `count` destinations from a root's navigation path.
    ///
    /// The selected root is used when `root` is omitted. Specifying a root also
    /// selects it. Nonpositive counts and unconfigured roots are no-ops.
    func navigateBack(
        _ count: Int = 1,
        on root: Destination? = nil
    ) {
        guard count > 0 else {
            return
        }

        let targetRoot = root ?? selectedRoot

        guard let configuredRoot = self.root(for: targetRoot) else {
            return
        }

        if !configuredRoot.path.isEmpty {
            configuredRoot.path.removeLast(min(count, configuredRoot.path.count))
        }

        updateSelection(to: targetRoot)
    }

    /// Removes every destination from a root's navigation path.
    ///
    /// The selected root is used when `root` is omitted. Specifying a root also
    /// selects it. An unconfigured root is a no-op.
    func returnToRoot(on root: Destination? = nil) {
        let targetRoot = root ?? selectedRoot

        guard let configuredRoot = self.root(for: targetRoot) else {
            return
        }

        if !configuredRoot.path.isEmpty {
            configuredRoot.path.removeAll()
        }

        updateSelection(to: targetRoot)
    }

    /// Replaces a root's complete navigation path.
    ///
    /// The selected root is used when `root` is omitted. Specifying a root also
    /// selects it. Equal paths avoid an unnecessary observation update, and an
    /// unconfigured root is a no-op.
    func replacePath(
        with path: [Destination],
        on root: Destination? = nil
    ) {
        let targetRoot = root ?? selectedRoot

        guard let configuredRoot = self.root(for: targetRoot) else {
            return
        }

        if configuredRoot.path != path {
            configuredRoot.path = path
        }

        updateSelection(to: targetRoot)
    }

    /// Reads a root's navigation path.
    ///
    /// An unconfigured root reads as an empty path.
    subscript(root: Destination) -> [Destination] {
        self.root(for: root)?.path ?? []
    }
}

extension NavigationController {
    func root(for destination: Destination) -> NavigationRoot<Destination>? {
        roots.first(where: { $0.destination == destination })
    }

    func updateSelection(to root: Destination) {
        guard self.root(for: root) != nil, selectedRoot != root else {
            return
        }

        selectedRoot = root
    }

    func navigatePath(
        _ path: inout [Destination],
        to destination: Destination
    ) {
        guard let index = path.firstIndex(of: destination) else {
            path.append(destination)
            return
        }

        let removalStart = path.index(after: index)

        guard removalStart != path.endIndex else {
            return
        }

        path.removeSubrange(removalStart..<path.endIndex)
    }
}
