//
//  NavigationSurfaceOverlay.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 24/09/2026.
//

import SwiftUI

/// An optional renderer for each native navigation surface, independent of its destination type.
/// Type erasure is confined to the overlay; the navigation content keeps its concrete type.
@MainActor
protocol NavigationSurfaceOverlay: Sendable {
    func makeView(in container: CGRect, contentBounds: CGRect?) -> AnyView
}

private struct NavigationSurfaceOverlayKey: EnvironmentKey {
    static let defaultValue: (any NavigationSurfaceOverlay)? = nil
}

extension EnvironmentValues {
    var navigationSurfaceOverlay: (any NavigationSurfaceOverlay)? {
        get { self[NavigationSurfaceOverlayKey.self] }
        set { self[NavigationSurfaceOverlayKey.self] = newValue }
    }
}

extension View {
    func navigationSurfaceOverlay<Overlay: View>(
        isEnabled: Bool = true,
        @ViewBuilder overlay: @escaping (CGRect, CGRect?) -> Overlay
    ) -> some View {
        overlayPreferenceValue(NavigationContentBoundsKey.self) { anchor in
            if isEnabled {
                GeometryReader { geometry in
                    overlay(
                        CGRect(origin: .zero, size: geometry.size),
                        anchor.map { geometry[$0] }
                    )
                }
            }
        }
    }
}
