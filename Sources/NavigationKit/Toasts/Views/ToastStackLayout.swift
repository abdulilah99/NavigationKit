//
//  ToastStackLayout.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 22/09/2026.
//

import SwiftUI

/// The newest card determines the deck's size; older cards receive that same size.
struct ToastStackLayout: Layout {
    let edge: VerticalEdge
    let maximumWidth: CGFloat
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let front = subviews.last else { return .zero }
        let peek = CGFloat(subviews.count - 1) * spacing
        let width = min(proposal.width ?? maximumWidth, maximumWidth)
        let size = front.sizeThatFits(ProposedViewSize(width: width, height: nil))
        return CGSize(
            width: min(size.width, width),
            height: min(size.height + peek, proposal.height ?? .infinity)
        )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let peek = CGFloat(max(subviews.count - 1, 0)) * spacing
        let height = max(bounds.height - peek, 0)
        let origin = CGPoint(x: bounds.minX, y: bounds.minY + (edge == .top ? peek : 0))

        for subview in subviews {
            subview.place(
                at: origin,
                anchor: .topLeading,
                proposal: ProposedViewSize(width: bounds.width, height: height)
            )
        }
    }
}
