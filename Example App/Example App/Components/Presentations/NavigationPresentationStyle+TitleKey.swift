import NavigationKit
import SwiftUI

extension NavigationPresentationStyle {
    var titleKey: LocalizedStringKey {
        switch self {
        case .sheet:
            "Sheet"
        case .fullScreen:
            "Full screen"
        }
    }
}
