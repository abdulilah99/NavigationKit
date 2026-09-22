//
//  ToastControlsSection.swift
//  Example App
//
//  Created by Abdulilah Imad on 22/09/2026.
//

import NavigationKit
import SwiftUI

struct ToastControlsSection: View {
    @Environment(ToastController<ExampleToast>.self) private var toasts
    @State private var number = 0

    var body: some View {
        Section("Toast decks") {
            Button("Show a toast") {
                number += 1
                toasts.show(.message(number))
            }

            Button("Stack five persistent toasts") {
                for value in 1...5 {
                    toasts.show(.message(value), expiration: .never)
                }
            }

            Button("Show a top error") {
                toasts.show(.error(title: "Upload failed", message: "Check your connection and try again."))
            }

            Button("Show a toast with a fixed deadline") {
                number += 1
                toasts.show(.message(number), expiration: .at(.now.addingTimeInterval(8)), alignment: .trailing)
            }

            Button("Update the latest toast") {
                if let toast = toasts.presentations.last {
                    toasts.update(id: toast.id, with: .saved, expiration: .after(.seconds(3)))
                }
            }
            .disabled(toasts.presentations.isEmpty)

            Button("Dismiss all toasts") {
                toasts.dismissAll()
            }

            Text("\(toasts.presentations.count) active toasts")
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("toast-count")
        }
    }
}
