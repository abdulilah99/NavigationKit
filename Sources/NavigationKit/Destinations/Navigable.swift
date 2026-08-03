//
//  Navigable.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 2/24/24.
//

import SwiftUI

/// A type-safe destination that NavigationKit can display anywhere.
///
/// One conforming type describes roots, destinations in a navigation path,
/// and modal destinations. A destination's value supplies its identity while
/// its metadata supplies the standard label and view used by NavigationKit.
public protocol Navigable: Identifiable, Hashable {
    /// The SwiftUI view associated with this destination.
    associatedtype Content: View

    /// The modifier applied whenever NavigationKit displays this destination.
    associatedtype Modifier: ViewModifier = EmptyModifier

    /// The localizable key used for the destination's standard title.
    var titleKey: LocalizedStringKey { get }

    /// The image used for the destination's standard icon.
    var icon: Image { get }

    /// The view displayed when navigating to this destination.
    @ViewBuilder var content: Content { get }

    /// Shared behavior and styling for this destination's view.
    ///
    /// NavigationKit applies the modifier whether the destination is displayed
    /// as a root, a route, or a modal presentation. Return a custom modifier to
    /// provide behavior such as navigation titles, environment dependencies,
    /// toolbars, or lifecycle handling from one place.
    @MainActor var modifier: Modifier { get }
}

public extension Navigable where Modifier == EmptyModifier {
    /// The default modifier, which leaves the destination view unchanged.
    @MainActor var modifier: EmptyModifier { EmptyModifier() }
}
