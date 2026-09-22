//
//  ToastController.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 22/09/2026.
//

import Combine
import Foundation
import Observation
import SwiftUI

/// Owns typed toast occurrences and their lifetimes independently from the host view.
@Observable
@MainActor
public final class ToastController<Toast: Toastable> {
    /// Active occurrences, ordered oldest first.
    public private(set) var presentations: [ToastPresentation<Toast>] = []

    @ObservationIgnored private let clock: ToastClock
    @ObservationIgnored private var expirationTask: Task<Void, Never>?
    @ObservationIgnored private var clockChanges: AnyCancellable?
    @ObservationIgnored private var dismissalActions: [
        UUID: @MainActor (ToastDismissalReason) -> Void
    ] = [:]

    public convenience init() {
        self.init(clock: ToastClock())
    }

    init(clock: ToastClock) {
        self.clock = clock
        clockChanges = NotificationCenter.default
            .publisher(for: .NSSystemClockDidChange)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.removeExpiredToasts()
                }
            }
    }

    deinit {
        expirationTask?.cancel()
    }

    /// Shows an independent occurrence using the toast's defaults or explicit overrides.
    /// Nonpositive durations and dates in the past are rejected without a callback.
    @discardableResult
    public func show(
        _ toast: Toast,
        expiration: ToastExpiration? = nil,
        edge: VerticalEdge? = nil,
        alignment: ToastAlignment? = nil,
        onDismiss: (@MainActor (ToastDismissalReason) -> Void)? = nil
    ) -> ToastPresentation<Toast>? {
        let expiration = expiration ?? toast.expiration
        guard isValid(expiration) else { return nil }

        let presentation = ToastPresentation(
            toast: toast,
            edge: edge ?? toast.edge,
            alignment: alignment ?? toast.alignment,
            expiration: expiration,
            clock: clock
        )
        presentations.append(presentation)
        dismissalActions[presentation.id] = onDismiss
        removeExpiredToasts()
        return presentation
    }

    /// Replaces content without changing identity, position, or expiration.
    /// Supply overrides to move the occurrence or restart/change its lifetime.
    /// Missing IDs are ignored. An already elapsed override expires the occurrence.
    public func update(
        id: ToastPresentation<Toast>.ID,
        with toast: Toast,
        expiration: ToastExpiration? = nil,
        edge: VerticalEdge? = nil,
        alignment: ToastAlignment? = nil
    ) {
        guard let presentation = presentations.first(where: { $0.id == id }) else {
            return
        }

        if let expiration, !isValid(expiration) {
            remove(ids: [id], reason: .expired)
            return
        }

        presentation.toast = toast
        if let edge { presentation.edge = edge }
        if let alignment { presentation.alignment = alignment }
        if let expiration { presentation.resolve(expiration, clock: clock) }
        removeExpiredToasts()
    }

    public func dismiss(id: ToastPresentation<Toast>.ID) {
        remove(ids: [id], reason: .dismissed)
    }

    public func dismissAll() {
        remove(ids: Set(presentations.map(\.id)), reason: .dismissed)
    }

    /// Reconciles deadlines immediately, for example when a custom host becomes active.
    public func removeExpiredToasts() {
        let expired = presentations.filter {
            if let remaining = $0.remaining(using: clock) {
                return remaining <= .zero
            }
            return false
        }
        remove(ids: Set(expired.map(\.id)), reason: .expired)
    }

    private func isValid(_ expiration: ToastExpiration) -> Bool {
        switch expiration {
        case .after(let duration): duration > .zero
        case .at(let date):
            date.timeIntervalSinceReferenceDate.isFinite && date > clock.date()
        case .never: true
        }
    }

    private func remove(ids: Set<UUID>, reason: ToastDismissalReason) {
        let removed = presentations.filter { ids.contains($0.id) }
        if !removed.isEmpty {
            presentations.removeAll { ids.contains($0.id) }
        }
        let actions = removed.compactMap { dismissalActions.removeValue(forKey: $0.id) }
        scheduleExpiration()

        // Detach all actions before running user code, which may mutate this controller.
        for action in actions { action(reason) }
    }

    private func scheduleExpiration() {
        expirationTask?.cancel()
        expirationTask = nil

        guard let delay = presentations.compactMap({ $0.remaining(using: clock) }).min() else {
            return
        }

        let sleep = clock.sleep
        expirationTask = Task { [weak self] in
            do {
                try await sleep(max(delay, .zero))
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            self?.removeExpiredToasts()
        }
    }
}
