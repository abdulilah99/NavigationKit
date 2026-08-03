import NavigationKit
import SwiftUI

struct ContentView: View {
    @Environment(NavigationController<Page>.self) private var navigation
    @State private var viewStyle = ExampleViewStyle.native

    var body: some View {
        VStack(spacing: 0) {
            ViewStylePicker(selection: $viewStyle)

            switch viewStyle {
            case .native:
                navigation.makeView()
            case .custom:
                CustomNavigationView(navigation: navigation)
                    .navigationPresentations(for: navigation)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(makeExampleNavigationController())
}
