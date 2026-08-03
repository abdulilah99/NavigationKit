import SwiftUI

struct SearchView: View {
    @State private var query = ""

    private var results: [Int] {
        guard let requestedID = Int(query) else {
            return Array(1...5)
        }

        return [requestedID]
    }

    var body: some View {
        List(results, id: \.self) { id in
            NavigationLink(value: Page.article(id))
        }
        .navigationTitle("Search")
        .searchable(text: $query, prompt: "Article number")
    }
}
