import NavigationKit
import SwiftUI

struct PresentationStateSection: View {
    let navigation: NavigationController<Page>

    var body: some View {
        Section("Presentation stack") {
            if navigation.presentations.isEmpty {
                Text("No modal presentations")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(navigation.presentations) { presentation in
                    HStack {
                        Label(
                            title: {
                                Text(presentation.destination.titleKey)
                            },
                            icon: { presentation.destination.icon }
                        )

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text(presentation.style.titleKey)
                            Text("\(presentation.path.count) destinations")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}
