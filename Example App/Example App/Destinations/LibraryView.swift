import SwiftUI

struct LibraryView: View {
    private let articleIDs = 1...8

    var body: some View {
        List(articleIDs, id: \.self) { id in
            NavigationLink(value: Page.article(id))
        }
    }
}
