//
//  NC+PresentationState.swift
//  NavigationKit
//

extension NavigationController {
    func presentation(
        id: NavigationPresentation<Destination>.ID
    ) -> NavigationPresentation<Destination>? {
        presentations.first(where: { $0.id == id })
    }

    func presentation(at index: Int) -> NavigationPresentation<Destination>? {
        guard presentations.indices.contains(index) else {
            return nil
        }

        return presentations[index]
    }

    func removePresentations(from index: Int) {
        guard presentations.indices.contains(index) else {
            return
        }

        let dismissedPresentations = Array(presentations[index...].reversed())
        presentations.removeSubrange(index...)

        let dismissalActions = dismissedPresentations.compactMap { presentation in
            takeDismissalAction(for: presentation.id)
        }

        for action in dismissalActions {
            action()
        }
    }
}
