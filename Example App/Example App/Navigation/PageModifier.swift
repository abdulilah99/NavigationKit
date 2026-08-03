import SwiftUI

/// Applies view behavior shared by every example destination.
struct PageModifier: ViewModifier {
    let titleKey: LocalizedStringKey

    func body(content: Content) -> some View {
        content.navigationTitle(titleKey)
    }
}
