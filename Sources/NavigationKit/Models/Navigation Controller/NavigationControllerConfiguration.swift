//
//  NavigationControllerConfiguration.swift
//  NavigationKit
//

/// Controller-wide navigation policies that can change at runtime.
///
/// Updating a configuration changes future controller operations. It does not
/// rewrite existing root paths or presentations.
public struct NavigationControllerConfiguration: Hashable, Sendable {
    /// The style used by `present` when no explicit style is supplied.
    public var defaultPresentationStyle: NavigationPresentationStyle

    /// The maximum number of simultaneously retained presentations.
    ///
    /// A value of zero disables new presentations. Lowering the value below
    /// the current stack depth preserves the existing stack while preventing
    /// new presentations until the stack is below the limit.
    public var maximumPresentationDepth: Int {
        didSet {
            Self.validate(maximumPresentationDepth: maximumPresentationDepth)
        }
    }

    public init(
        defaultPresentationStyle: NavigationPresentationStyle = .sheet,
        maximumPresentationDepth: Int = 8
    ) {
        Self.validate(maximumPresentationDepth: maximumPresentationDepth)

        self.defaultPresentationStyle = defaultPresentationStyle
        self.maximumPresentationDepth = maximumPresentationDepth
    }

    public static let `default` = Self()

    private static func validate(maximumPresentationDepth: Int) {
        precondition(
            maximumPresentationDepth >= 0,
            "Maximum presentation depth cannot be negative."
        )
    }
}
