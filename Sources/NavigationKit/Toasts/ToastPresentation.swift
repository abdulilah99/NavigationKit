//
//  ToastPresentation.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 22/09/2026.
//

import Foundation
import Observation
import SwiftUI

/// One occurrence of a toast. Equal content may have multiple independent occurrences.
@Observable
@MainActor
public final class ToastPresentation<Toast: Toastable>: Identifiable, Equatable {
    public let id: UUID
    public internal(set) var toast: Toast
    public internal(set) var edge: VerticalEdge
    public internal(set) var alignment: ToastAlignment
    public internal(set) var expiration: ToastExpiration

    /// The date resolved at the last expiration update, or `nil` for `.never`.
    /// For `.after`, scheduling uses elapsed time even if the system clock changes.
    public internal(set) var expiresAt: Date?

    @ObservationIgnored var deadline: ContinuousClock.Instant?

    init(
        toast: Toast,
        edge: VerticalEdge,
        alignment: ToastAlignment,
        expiration: ToastExpiration,
        clock: ToastClock
    ) {
        id = UUID()
        self.toast = toast
        self.edge = edge
        self.alignment = alignment
        self.expiration = expiration
        resolve(expiration, clock: clock)
    }

    public nonisolated static func == (
        lhs: ToastPresentation<Toast>,
        rhs: ToastPresentation<Toast>
    ) -> Bool {
        lhs.id == rhs.id
    }

    func resolve(_ expiration: ToastExpiration, clock: ToastClock) {
        self.expiration = expiration

        switch expiration {
        case .after(let duration):
            deadline = clock.now().advanced(by: duration)
            let components = duration.components
            let seconds = Double(components.seconds)
                + Double(components.attoseconds) / 1e18
            expiresAt = clock.date().addingTimeInterval(seconds)
        case .at(let date):
            deadline = nil
            expiresAt = date
        case .never:
            deadline = nil
            expiresAt = nil
        }
    }

    func remaining(using clock: ToastClock) -> Duration? {
        if let deadline {
            return clock.now().duration(to: deadline)
        }

        if let expiresAt {
            return .seconds(expiresAt.timeIntervalSince(clock.date()))
        }

        return nil
    }
}
