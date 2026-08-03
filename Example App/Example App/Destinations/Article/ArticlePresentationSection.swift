import NavigationKit
import SwiftUI

struct ArticlePresentationSection: View {
    let id: Int
    let navigation: NavigationController<Page>

    var body: some View {
        Section("Modal stacking") {
            Button("Present Article \(id + 1) as a sheet") {
                navigation.present(.article(id + 1), as: .sheet)
            }

            Button("Present this article again") {
                navigation.present(.article(id), as: .sheet)
            }

            Button("Present Player \(id) full screen") {
                navigation.present(.player(id), as: .fullScreen)
            }
        }
    }
}
