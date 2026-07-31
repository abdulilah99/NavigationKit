//
//  NavigationSurfacePolicy.swift
//  NavigationKit
//

/// The semantic environment in which root navigation is presented.
///
/// Applications can use these values to describe placement without depending
/// on SwiftUI size classes or platform checks.
public enum NavigationPresentationContext: Hashable, Sendable {
    case compact
    case expanded
    case television
    case desktop
    case spatial
}

/// The navigation chrome in which a configured root can appear.
///
/// An empty set requests that the root be hidden from navigation chrome. The
/// root remains in the catalog and can still be selected programmatically.
/// Hosts may use a documented fallback where the platform cannot hide a root.
public struct NavigationSurfaces: OptionSet, Hashable, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let tabBar = Self(rawValue: 1 << 0)
    public static let sidebar = Self(rawValue: 1 << 1)
    public static let all: Self = [.tabBar, .sidebar]
}

/// App-owned placement data for a configured navigation root.
public struct NavigationSurfacePolicy: Hashable, Sendable {
    public let compact: NavigationSurfaces
    public let expanded: NavigationSurfaces
    public let television: NavigationSurfaces
    public let desktop: NavigationSurfaces
    public let spatial: NavigationSurfaces

    /// Uses the same surfaces in every presentation context.
    public init(_ surfaces: NavigationSurfaces) {
        self.init(
            compact: surfaces,
            expanded: surfaces,
            television: surfaces,
            desktop: surfaces,
            spatial: surfaces
        )
    }

    public init(
        compact: NavigationSurfaces = .all,
        expanded: NavigationSurfaces = .all,
        television: NavigationSurfaces = .all,
        desktop: NavigationSurfaces = .all,
        spatial: NavigationSurfaces = .all
    ) {
        self.compact = compact
        self.expanded = expanded
        self.television = television
        self.desktop = desktop
        self.spatial = spatial
    }

    public func surfaces(
        in context: NavigationPresentationContext
    ) -> NavigationSurfaces {
        switch context {
        case .compact:
            compact
        case .expanded:
            expanded
        case .television:
            television
        case .desktop:
            desktop
        case .spatial:
            spatial
        }
    }
}
