import SwiftUI

enum NavigationViewMode: CaseIterable, Identifiable {
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

/// Switches between NavigationKit's native view and app-defined navigation
/// chrome so both integration styles can be tested with the same controller.
struct NavigationViewModePicker: View {
    @Binding var selection: NavigationViewMode

    var body: some View {
        Picker("Navigation view", selection: $selection) {
            ForEach(NavigationViewMode.allCases) { mode in
                Text(mode.titleKey)
                    .tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.08))
    }
}
