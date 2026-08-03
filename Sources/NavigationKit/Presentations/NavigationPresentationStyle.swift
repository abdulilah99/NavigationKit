//
//  NavigationPresentationStyle.swift
//  NavigationKit
//

/// The native container used for one layer in a presentation stack.
public enum NavigationPresentationStyle: Hashable, Sendable {
    /// Presents the destination using the platform's native sheet.
    case sheet

    /// Presents the destination using a native full-screen cover where
    /// available, with a sheet fallback on macOS and visionOS.
    case fullScreen
}
