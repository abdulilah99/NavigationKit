//
//  NavigationDestinationVisibility.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 02/10/2026.
//

import SwiftUI

public extension EnvironmentValues {
    /// Whether this destination is at the front of its selected root or modal stack.
    ///
    /// Use `NavigationRoot.content(for:)` in custom containers to account for
    /// root selection. Native presentations use occurrence identity, so equal
    /// destinations in different modal layers have independent visibility.
    /// Within a path, identity follows destination equality. This value describes
    /// navigation state, not scene activity or local sheets.
    @Entry var isNavigationDestinationVisible = true
}
