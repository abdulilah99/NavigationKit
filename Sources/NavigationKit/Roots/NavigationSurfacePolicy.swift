//
//  NavigationSurfacePolicy.swift
//  NavigationKit
//

/// The semantic environment in which root navigation is presented.
///
/// Applications can use these values to describe placement without depending
/// on SwiftUI size classes or platform checks.
public enum NavigationSurfaceContext: Hashable, Sendable {
    /// A compact mobile presentation, such as a narrow iPhone window.
    case compact

    /// A regular mobile presentation, such as an iPad window.
    case regular

    /// A television presentation on tvOS.
    case television

    /// A desktop presentation on macOS.
    case desktop

    /// A spatial presentation on visionOS.
    case spatial
}

/// The navigation chrome in which a configured root can appear.
///
/// An empty set requests that the root be hidden from navigation chrome. The
/// root remains in the catalog and can still be selected programmatically.
/// Navigation views may use a documented fallback where a root cannot be hidden.
public struct NavigationSurfaces: OptionSet, Hashable, Sendable {
    /// The underlying bit set for these surfaces.
    public let rawValue: Int

    /// Creates a surface set from its underlying bit set.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// The platform's tab-bar navigation surface.
    public static let tabBar = Self(rawValue: 1 << 0)

    /// The platform's sidebar navigation surface.
    public static let sidebar = Self(rawValue: 1 << 1)

    /// Every navigation surface supported by NavigationKit.
    public static let all: Self = [.tabBar, .sidebar]
}

/// App-owned placement data for a configured navigation root.
public struct NavigationSurfacePolicy: Hashable, Sendable {
    /// Surfaces requested in compact mobile presentations.
    public let compact: NavigationSurfaces

    /// Surfaces requested in regular mobile presentations.
    public let regular: NavigationSurfaces

    /// Surfaces requested on tvOS.
    public let television: NavigationSurfaces

    /// Surfaces requested on macOS.
    public let desktop: NavigationSurfaces

    /// Surfaces requested on visionOS.
    public let spatial: NavigationSurfaces

    /// Uses the same surfaces in every presentation context.
    public init(_ surfaces: NavigationSurfaces) {
        self.init(
            compact: surfaces,
            regular: surfaces,
            television: surfaces,
            desktop: surfaces,
            spatial: surfaces
        )
    }

    /// Creates a policy with independent placement for every context.
    public init(
        compact: NavigationSurfaces = .all,
        regular: NavigationSurfaces = .all,
        television: NavigationSurfaces = .all,
        desktop: NavigationSurfaces = .all,
        spatial: NavigationSurfaces = .all
    ) {
        self.compact = compact
        self.regular = regular
        self.television = television
        self.desktop = desktop
        self.spatial = spatial
    }

    /// Returns the surfaces configured for a semantic presentation context.
    public func surfaces(
        in context: NavigationSurfaceContext
    ) -> NavigationSurfaces {
        switch context {
        case .compact:
            compact
        case .regular:
            regular
        case .television:
            television
        case .desktop:
            desktop
        case .spatial:
            spatial
        }
    }
}
