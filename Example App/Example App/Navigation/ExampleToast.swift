//
//  ExampleToast.swift
//  Example App
//
//  Created by Abdulilah Imad on 22/09/2026.
//

import NavigationKit
import SwiftUI

enum ExampleToast: Toastable, Equatable {
    case error(title: LocalizedStringResource, message: LocalizedStringResource)
    case message(Int)
    case saved

    var expiration: ToastExpiration {
        switch self {
        case .error: .after(.seconds(8))
        case .message: .after(.seconds(4))
        case .saved: .after(.seconds(3))
        }
    }

    var edge: VerticalEdge {
        switch self {
        case .error: .top
        case .message, .saved: .bottom
        }
    }

    @ViewBuilder
    var content: some View {
        switch self {
        case .error(let title, let message):
            ExampleToastView(title: title, message: message, symbol: "exclamationmark.triangle.fill", color: .orange)
        case .message(let number):
            ExampleToastView(title: "Toast \(number)", message: "Swipe left or right to reveal the next toast.", symbol: "bell.fill", color: .blue)
        case .saved:
            ExampleToastView(title: "Saved", message: "This toast was updated without changing its identity.", symbol: "checkmark.circle.fill", color: .green)
        }
    }
}
