//
//  Toastable.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 22/09/2026.
//

import SwiftUI

/// App-defined toast content and defaults, independent from navigation destinations.
@MainActor
public protocol Toastable {
    associatedtype Content: View

    @ViewBuilder var content: Content { get }
    var expiration: ToastExpiration { get }
    var edge: VerticalEdge { get }
    var alignment: ToastAlignment { get }
    /// An optional custom transition. `nil` slides from the occurrence's resolved edge.
    var transition: AnyTransition? { get }
}

public extension Toastable {
    var expiration: ToastExpiration { .after(.seconds(4)) }
    var edge: VerticalEdge { .bottom }
    var alignment: ToastAlignment { .center }
    var transition: AnyTransition? { nil }
}

/// Semantic horizontal placement within a toast's top or bottom stack.
public enum ToastAlignment: Hashable, Sendable, CaseIterable {
    case leading
    case center
    case trailing
}
