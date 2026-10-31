//
//  NativeTabImages.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 31/10/2026.
//

#if os(iOS)
import SwiftUI
import UIKit

/// Supplies selected artwork for every tab, including content that has not appeared yet.
@available(iOS 26.1, *)
struct NativeTabImages: UIViewControllerRepresentable {
    struct Pair {
        let icon: Image
        let selectedIcon: Image

        @MainActor
        func renderSelectedImage(matching source: UIImage, environment: EnvironmentValues) -> UIImage? {
            guard icon != selectedIcon else { return nil }

            let renderer = ImageRenderer(content: selectedIcon
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: source.size.width, height: source.size.height)
                .environment(\.self, environment)
                .foregroundStyle(.black)
            )
            renderer.scale = environment.displayScale
            return renderer.uiImage?.withRenderingMode(source.renderingMode)
        }
    }

    let pairs: [Pair]
    let isActive: Bool

    func makeUIViewController(context: Context) -> Controller {
        Controller()
    }

    func updateUIViewController(_ controller: Controller, context: Context) {
        controller.update(pairs: pairs, isActive: isActive, environment: context.environment)
    }

    final class Controller: UIViewController {
        private var pendingUpdate: ((UITabBarController) -> Bool)?

        override func loadView() {
            view = UIView()
            view.isUserInteractionEnabled = false
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            guard let tabBarController, let pendingUpdate else { return }
            if pendingUpdate(tabBarController) {
                self.pendingUpdate = nil
            }
        }

        func update(pairs: [Pair], isActive: Bool, environment: EnvironmentValues) {
            guard isActive else {
                pendingUpdate = nil
                return
            }

            // SwiftUI may still be configuring the native tabs during an update.
            pendingUpdate = { tabBarController in
                let tabs = tabBarController.tabs
                guard tabs.count == pairs.count else { return false }

                // Native tabs follow root order, including sidebar-only roots.
                for (pair, tab) in zip(pairs, tabs) {
                    guard let source = tab.image else { continue }
                    tab.selectedImage = pair.renderSelectedImage(matching: source, environment: environment)
                }
                return true
            }
            view.setNeedsLayout()
        }
    }
}
#endif
