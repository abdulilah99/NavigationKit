import NavigationKit
import SwiftUI

struct FiltersView: View {
    @Environment(NavigationController<Page>.self) private var navigation
    @State private var includesReadArticles = true
    @State private var newestFirst = true

    var body: some View {
        List {
            ToastControlsSection()

            Section("Example filters") {
                Toggle("Include read articles", isOn: $includesReadArticles)
                Toggle("Newest first", isOn: $newestFirst)
            }

            Section("Continue the modal stack") {
                Button("Present Article 30") {
                    navigation.present(.article(30), as: .sheet)
                }

                Button("Present Player 3 full screen") {
                    navigation.present(.player(3), as: .fullScreen)
                }
            }

            PresentationControlsSection(navigation: navigation)
            PresentationStateSection(navigation: navigation)
        }
    }
}
