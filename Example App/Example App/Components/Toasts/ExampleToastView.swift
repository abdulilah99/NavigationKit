//
//  ExampleToastView.swift
//  Example App
//
//  Created by Abdulilah Imad on 22/09/2026.
//

import NavigationKit
import SwiftUI

struct ExampleToastView: View {
    let title: LocalizedStringResource
    let message: LocalizedStringResource
    let symbol: String
    let color: Color

    @Environment(ToastController<ExampleToast>.self) private var toasts
    @Environment(ToastPresentation<ExampleToast>.self) private var presentation

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(message).font(.subheadline).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                toasts.dismiss(id: presentation.id)
            } label: {
                Label("Dismiss toast", systemImage: "xmark.circle.fill")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(color.opacity(0.3))
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("toast-card")
    }
}
