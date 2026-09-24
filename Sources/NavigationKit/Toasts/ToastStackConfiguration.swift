//
//  ToastStackConfiguration.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 22/09/2026.
//

import SwiftUI

/// Layout and interaction shared by the top and bottom notification decks.
public struct ToastStackConfiguration {
    /// The layout region used by a toast host. All cases retain the host's safe area.
    public enum Placement: Hashable, Sendable {
        /// Top toasts use the container's top; bottom toasts clear content's bottom chrome.
        case automatic
        /// Both decks use the container's safe edges, allowing overlap with navigation chrome.
        case container
        /// Both decks stay within the active destination's content bounds.
        case content
    }

    public let maximumVisibleToasts: Int
    public let maximumWidth: CGFloat
    public let stackSpacing: CGFloat
    public let scaleStep: CGFloat
    public let insets: EdgeInsets
    public let animation: Animation?
    public let swipeThreshold: CGFloat
    public let placement: Placement

    public init(
        maximumVisibleToasts: Int = 3,
        maximumWidth: CGFloat = 420,
        stackSpacing: CGFloat = 8,
        scaleStep: CGFloat = 0.05,
        insets: EdgeInsets = EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16),
        animation: Animation? = .spring(duration: 0.3, bounce: 0.15),
        swipeThreshold: CGFloat = 60,
        placement: Placement = .automatic
    ) {
        precondition(maximumVisibleToasts > 0, "At least one toast must be visible.")
        precondition(maximumWidth.isFinite && maximumWidth > 0, "Toast width must be positive and finite.")
        precondition(stackSpacing.isFinite && stackSpacing >= 0, "Toast spacing must be nonnegative and finite.")
        precondition(scaleStep.isFinite && (0..<1).contains(scaleStep), "Toast scale step must be between zero and one.")
        precondition(swipeThreshold.isFinite && swipeThreshold > 0, "Swipe threshold must be positive and finite.")

        self.maximumVisibleToasts = maximumVisibleToasts
        self.maximumWidth = maximumWidth
        self.stackSpacing = stackSpacing
        self.scaleStep = scaleStep
        self.insets = insets
        self.animation = animation
        self.swipeThreshold = swipeThreshold
        self.placement = placement
    }
}

extension ToastStackConfiguration.Placement {
    func bounds(in container: CGRect, content: CGRect?) -> CGRect {
        guard self != .container, let content else { return container }
        let visibleContent = container.intersection(content)
        guard !visibleContent.isEmpty else { return container }

        switch self {
        case .automatic:
            return CGRect(
                x: visibleContent.minX,
                y: container.minY,
                width: visibleContent.width,
                height: visibleContent.maxY - container.minY
            )
        case .content:
            return visibleContent
        case .container:
            return container
        }
    }
}
