//
//  PresentationDirectionFixture.swift
//  Example App
//
//  Created by Abdulilah Imad on 24/09/2026.
//

#if DEBUG
import NavigationKit
import SwiftUI

/// Exercises app-level language overrides across real native presentation boundaries.
struct PresentationDirectionFixture: View {
    let rightToLeft: Bool
    @State private var navigation = NavigationController(roots: [NavigationRoot(destination: DirectionPage(depth: 0))])
    @State private var toasts = ToastController<DirectionToast>()

    var body: some View {
        navigation.makeView()
            .navigationToasts(for: toasts, configuration: .init(maximumWidth: 180))
            .environment(navigation)
            .environment(toasts)
            .environment(\.locale, Locale(identifier: rightToLeft ? "ar_IQ" : "en_US"))
            .environment(\.layoutDirection, rightToLeft ? .rightToLeft : .leftToRight)
    }
}

private struct DirectionPage: Navigable {
    let depth: Int
    var id: Self { self }
    var titleKey: LocalizedStringKey { "Direction" }
    var icon: Image { Image(systemName: "arrow.left.arrow.right") }
    var content: some View { DirectionSurface(depth: depth) }
}

private struct DirectionSurface: View {
    let depth: Int
    @Environment(\.layoutDirection) private var direction
    @Environment(\.locale) private var locale
    @Environment(NavigationController<DirectionPage>.self) private var navigation
    @Environment(ToastController<DirectionToast>.self) private var toasts

    nonisolated init(depth: Int) { self.depth = depth }

    var body: some View {
        VStack(spacing: 16) {
            Text(verbatim: direction == .rightToLeft ? "RTL" : "LTR")
                .accessibilityIdentifier("direction-\(depth)")
            Text(verbatim: locale.identifier)
                .accessibilityIdentifier("locale-\(depth)")
            HStack {
                Text(verbatim: "Leading").accessibilityIdentifier("leading-\(depth)")
                Spacer()
                Text(verbatim: "Trailing").accessibilityIdentifier("trailing-\(depth)")
            }
            Button("Show timed toasts") {
                toasts.show(.leading)
                toasts.show(.trailing)
            }
            .accessibilityIdentifier("show-\(depth)")
            Button("Present sheet") { navigation.present(DirectionPage(depth: depth + 1), as: .sheet) }
                .accessibilityIdentifier("sheet-\(depth)")
            Button("Present cover") { navigation.present(DirectionPage(depth: depth + 1), as: .fullScreen) }
                .accessibilityIdentifier("cover-\(depth)")
            Button("Dismiss") { navigation.dismissPresentation() }
                .accessibilityIdentifier("dismiss-\(depth)")
            Text(verbatim: toasts.presentations.isEmpty ? "none" : toasts.presentations.map {
                "\($0.id.uuidString)|\($0.expiresAt?.timeIntervalSince1970 ?? 0)"
            }.joined(separator: ";"))
            .font(.caption2)
            .accessibilityIdentifier("occurrences-\(depth)")
        }
        .padding()
    }
}

private enum DirectionToast: Toastable {
    case leading, trailing

    var expiration: ToastExpiration { .after(.seconds(20)) }
    var edge: VerticalEdge { self == .leading ? .top : .bottom }
    var alignment: ToastAlignment { self == .leading ? .leading : .trailing }
    var content: some View { DirectionToastContent(toast: self) }
}

private struct DirectionToastContent: View {
    let toast: DirectionToast
    @Environment(\.layoutDirection) private var direction
    @Environment(\.locale) private var locale

    var body: some View {
        Text(verbatim: locale.language.languageCode?.identifier == "ar" ? "تم الحفظ" : "Saved")
            .padding()
            .frame(maxWidth: .infinity)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .accessibilityIdentifier(toast == .leading ? "leading-toast" : "trailing-toast")
            .accessibilityValue(direction == .rightToLeft ? "RTL" : "LTR")
    }
}
#endif
