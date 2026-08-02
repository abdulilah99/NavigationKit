//
//  NC+Functions.swift
//  NavigationKit
//
//  Created by Abdulilah on 03/03/2025.
//

public extension NavigationController {
    func select(root: Destination) {
        updateSelection(to: root)
    }

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

    subscript(root: Destination) -> [Destination] {
        get {
            self.root(for: root)?.path ?? []
        }
        set {
            self.root(for: root)?.path = newValue
        }
    }
}

extension NavigationController {
    func root(for destination: Destination) -> NavigationRoot<Destination>? {
        roots.first(where: { $0.destination == destination })
    }

    func updateSelection(to root: Destination) {
        guard self.root(for: root) != nil else {
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

        path.removeSubrange(path.index(after: index)..<path.endIndex)
    }
}
