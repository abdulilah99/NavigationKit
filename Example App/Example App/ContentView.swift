//
//  ContentView.swift
//  Example App
//
//  Created by Abdulilah on 23/03/2025.
//

import SwiftUI
import NavigationKit

struct ContentView: View {
    @Environment(NavigationController<Page>.self) private var navigation
    @State private var hostStyle: ExampleHostStyle = .native

    var body: some View {
        VStack(spacing: 0) {
            HostStylePicker(selection: $hostStyle)

            switch hostStyle {
            case .native:
                navigation.makeView()
            case .custom:
                CustomNavigationHost(navigation: navigation)
                    .navigationPresentations(for: navigation)
            }
        }
    }
}

private enum ExampleHostStyle: String, CaseIterable, Identifiable {
    case native = "Native host"
    case custom = "Custom chrome"

    var id: Self { self }
}

private struct HostStylePicker: View {
    @Binding var selection: ExampleHostStyle

    var body: some View {
        Picker("Navigation UI", selection: $selection) {
            ForEach(ExampleHostStyle.allCases) { style in
                Text(style.rawValue).tag(style)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.08))
    }
}

private struct CustomNavigationHost: View {
    let navigation: NavigationController<Page>

    var body: some View {
        VStack(spacing: 0) {
            if let selectedRoot = navigation.roots.first(
                where: { $0.destination == navigation.selectedRoot }
            ) {
                selectedRoot.content
            }

            Divider()
            CustomRootBar(navigation: navigation)
        }
    }
}

private struct CustomRootBar: View {
    let navigation: NavigationController<Page>

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(navigation.roots) { root in
                    Button {
                        navigation.select(root: root.destination)
                    } label: {
                        Label(
                            title: { Text(root.destination.titleKey) },
                            icon: { root.destination.icon }
                        )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)
                    .tint(
                        navigation.selectedRoot == root.destination
                            ? .accentColor
                            : .secondary
                    )
                    .accessibilityAddTraits(
                        navigation.selectedRoot == root.destination
                            ? .isSelected
                            : []
                    )
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .environment(makeExampleNavigationController())
}
