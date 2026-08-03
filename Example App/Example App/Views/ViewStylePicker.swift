import SwiftUI

struct ViewStylePicker: View {
    @Binding var selection: ExampleViewStyle

    var body: some View {
        Picker("Navigation view", selection: $selection) {
            ForEach(ExampleViewStyle.allCases) { style in
                Text(style.titleKey)
                    .tag(style)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.08))
    }
}
