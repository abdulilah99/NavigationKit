import SwiftUI

struct ArticleIdentitySection: View {
    let id: Int

    var body: some View {
        Section("Destination identity") {
            Text("Article \(id)")
            Text("The associated value makes every article a distinct destination.")
        }
    }
}
