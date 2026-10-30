//
//  NavigationIconTests.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 31/10/2026.
//

import SwiftUI
import Testing
@testable import NavigationKit

@MainActor
@Test
func selectedIconDefaultsToTheStandardIcon() {
    let destination = DefaultIconDestination()

    #expect(selectedIcon(for: destination) == destination.icon)
}

@MainActor
@Test
func selectedIconUsesTheConformersOverrideThroughTheProtocol() {
    let destination = SelectedIconDestination()

    #expect(selectedIcon(for: destination) == Image(systemName: "circle.fill"))
    #expect(selectedIcon(for: destination) != destination.icon)
}

// Native hosts access destinations through this generic protocol boundary too.
private func selectedIcon<Destination: Navigable>(for destination: Destination) -> Image {
    destination.selectedIcon
}

private struct DefaultIconDestination: Navigable {
    let id = 0
    var titleKey: LocalizedStringKey { "Default icon" }
    var icon: Image { Image(systemName: "circle") }
    var content: some View { Color.clear }
}

private struct SelectedIconDestination: Navigable {
    let id = 0
    var titleKey: LocalizedStringKey { "Selected icon" }
    var icon: Image { Image(systemName: "circle") }
    var selectedIcon: Image { Image(systemName: "circle.fill") }
    var content: some View { Color.clear }
}
