import SwiftUI

enum ExampleViewStyle: CaseIterable, Identifiable {
    case native
    case custom

    var id: Self { self }

    var titleKey: LocalizedStringKey {
        switch self {
        case .native:
            "Native view"
        case .custom:
            "Custom view"
        }
    }
}
