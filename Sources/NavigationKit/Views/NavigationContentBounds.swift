//
//  NavigationContentBounds.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 22/09/2026.
//

import SwiftUI

/// Carries the visible destination's safe layout area to its presentation host.
struct NavigationContentBoundsKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>? { nil }

    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = nextValue() ?? value
    }
}

extension View {
    func navigationContentBounds(isActive: Bool) -> some View {
        background {
            Color.clear
                .anchorPreference(key: NavigationContentBoundsKey.self, value: .bounds) {
                    isActive ? $0 : nil
                }
        }
    }
}
