//
//  ToastBindingState.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 22/09/2026.
//

import Foundation

/// Connects a view-owned binding to one controller occurrence.
@MainActor
final class ToastBindingState<Toast: Toastable> {
    let toasts: ToastController<Toast>
    private var presentationID: UUID?
    private var resetBinding: (() -> Void)?
    private var onDismiss: (() -> Void)?

    convenience init() {
        self.init(toasts: ToastController<Toast>())
    }

    init(toasts: ToastController<Toast>) {
        self.toasts = toasts
    }

    func synchronize(
        _ toast: Toast?,
        resetBinding: @escaping () -> Void,
        onDismiss: (() -> Void)?
    ) {
        guard let toast else {
            dismiss()
            return
        }

        self.resetBinding = resetBinding
        self.onDismiss = onDismiss

        if let presentationID {
            toasts.update(id: presentationID, with: toast)
            return
        }

        let presentation = toasts.show(toast) { [weak self] _ in
            self?.didDismiss()
        }
        if let presentation, toasts.presentations.contains(presentation) {
            presentationID = presentation.id
        } else if presentation == nil {
            self.resetBinding = nil
            self.onDismiss = nil
            resetBinding()
        }
    }

    func dismiss() {
        guard let presentationID else { return }
        toasts.dismiss(id: presentationID)
    }

    private func didDismiss() {
        let reset = resetBinding
        let action = onDismiss
        presentationID = nil
        resetBinding = nil
        onDismiss = nil
        reset?()
        action?()
    }
}
