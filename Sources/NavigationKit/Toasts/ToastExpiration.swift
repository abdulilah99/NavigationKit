//
//  ToastExpiration.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 22/09/2026.
//

import Foundation

/// A policy resolved once when a toast is shown or its expiration is updated.
public enum ToastExpiration: Hashable, Sendable {
    /// Elapsed time, including time spent in the background or asleep.
    case after(Duration)

    /// A wall-clock deadline, including subsequent system clock changes.
    case at(Date)

    /// Remains until explicitly dismissed.
    case never
}

/// Why an occurrence left the controller, before its exit animation completes.
public enum ToastDismissalReason: Hashable, Sendable {
    case dismissed
    case expired
}

@MainActor
struct ToastClock {
    var now: () -> ContinuousClock.Instant = { .now }
    var date: () -> Date = { .now }
    var sleep: (Duration) async throws -> Void = { duration in
        try await Task.sleep(for: duration, clock: .continuous)
    }
}
