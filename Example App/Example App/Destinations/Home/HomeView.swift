import NavigationKit
import SwiftUI

struct HomeView: View {
    @Environment(NavigationController<Page>.self) private var navigation

    var body: some View {
        List {
            Section("Typed links") {
                NavigationLink(value: Page.article(1))
                NavigationLink(value: Page.library)
            }

            RootNavigationCommandsSection(navigation: navigation)
            ModalPresentationCommandsSection(navigation: navigation)
            ControllerConfigurationSection(navigation: navigation)
            NavigationStateSection(navigation: navigation)
            PresentationStateSection(navigation: navigation)
        }
    }
}
