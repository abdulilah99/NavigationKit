import NavigationKit
import SwiftUI

struct PlayerView: View {
    let id: Int

    @Environment(NavigationController<Page>.self) private var navigation

    var body: some View {
        List {
            Section("Full-screen destination") {
                Label("Playing item \(id)", systemImage: "play.fill")
                Text("Full-screen presentations remain normal navigable destinations and can present another layer.")
            }

            Section("Continue the modal stack") {
                Button("Present player details") {
                    navigation.present(.article(id), as: .sheet)
                }

                Button("Present another Player \(id)") {
                    navigation.present(.player(id), as: .fullScreen)
                }
            }

            PresentationControlsSection(navigation: navigation)
            PresentationStateSection(navigation: navigation)
        }
    }
}
