//
//  ToastBindingDemoView.swift
//  Example App
//
//  Created by Abdulilah Imad on 22/09/2026.
//

import NavigationKit
import SwiftUI

struct ToastBindingDemoView: View {
    @State private var showsToast = false
    @State private var showsEnumToast = false
    @State private var toast: ExampleToast?
    @State private var expiresAutomatically = false
    @State private var allowsSwipeDismissal = true
    @State private var count = 0
    @State private var dismissals = 0

    nonisolated init() {}

    var body: some View {
        VStack(spacing: 0) {
            Text("Dismissals: \(dismissals)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(8)

            List {
                Section("Custom content") {
                    Toggle("Expire automatically", isOn: $expiresAutomatically)
                    Toggle("Allow swipe dismissal", isOn: $allowsSwipeDismissal)
                    Button("Show custom toast") { showsToast = true }
                    Button("Hide custom toast") { showsToast = false }
                    Text(showsToast ? "Custom binding: true" : "Custom binding: false")
                }

                Section("Enum content") {
                    Button("Show enum toast") {
                        toast = .error(title: "Bound toast", message: "Dismiss me to clear the optional binding.")
                    }
                    Button("Update enum toast") {
                        toast = .error(title: "Updated bound toast", message: "The original deadline is preserved.")
                    }
                    Text(toast == nil ? "Enum binding: nil" : "Enum binding: presented")
                }

                Section("Enum with a Boolean binding") {
                    Button("Show saved toast") { showsEnumToast = true }
                    Text(showsEnumToast ? "Boolean enum binding: true" : "Boolean enum binding: false")
                }
            }
        }
        .navigationTitle("Binding toasts")
        .toast(
            isPresented: $showsToast,
            expiration: expiresAutomatically ? .after(.seconds(2)) : .never,
            swipeToDismiss: allowsSwipeDismissal,
            onDismiss: { dismissals += 1 }
        ) {
            HStack {
                Text("Custom count: \(count)")
                Button("Increment") { count += 1 }
                Button("Close custom toast") { showsToast = false }
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("custom-toast")
        }
        .toast(item: $toast, onDismiss: { dismissals += 1 })
        .toast(isPresented: $showsEnumToast, toast: ExampleToast.saved, onDismiss: { dismissals += 1 })
    }
}
