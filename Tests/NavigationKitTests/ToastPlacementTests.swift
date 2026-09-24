import SwiftUI
import Testing
@testable import NavigationKit

@Test
func automaticToastPlacementKeepsTopStableWhenNavigationChromeChanges() {
    let container = CGRect(x: 0, y: 0, width: 800, height: 600)
    let expandedTitle = CGRect(x: 200, y: 120, width: 600, height: 420)
    let collapsedTitle = CGRect(x: 200, y: 44, width: 600, height: 496)
    let placement = ToastStackConfiguration.Placement.automatic
    let bounds = placement.bounds(in: container, content: expandedTitle)

    #expect(bounds == placement.bounds(in: container, content: collapsedTitle))
    #expect(bounds.minY == container.minY)
    #expect(bounds.maxY == expandedTitle.maxY)
    #expect(bounds.minX == expandedTitle.minX)
}

@Test
func toastPlacementCanClearOrOverlapNavigationChrome() {
    let container = CGRect(x: 0, y: 0, width: 400, height: 800)
    let content = CGRect(x: 0, y: 100, width: 400, height: 650)

    #expect(ToastStackConfiguration.Placement.container.bounds(in: container, content: content) == container)
    #expect(ToastStackConfiguration.Placement.content.bounds(in: container, content: content) == content)
}

@Test(arguments: [ToastStackConfiguration.Placement.automatic, .container, .content])
func toastPlacementFallsBackToItsHostWithoutUsableContent(placement: ToastStackConfiguration.Placement) {
    let container = CGRect(x: 0, y: 0, width: 400, height: 800)

    #expect(placement.bounds(in: container, content: nil) == container)
    #expect(placement.bounds(in: container, content: .zero) == container)
    #expect(placement.bounds(in: container, content: CGRect(x: 0, y: 900, width: 400, height: 100)) == container)
}

@Test(arguments: [ToastStackConfiguration.Placement.automatic, .container, .content])
func toastPlacementStaysInsideTheResizedHost(placement: ToastStackConfiguration.Placement) {
    // A keyboard or smaller sheet can shrink the host before the content updates.
    let container = CGRect(x: 0, y: 0, width: 400, height: 400)
    let content = CGRect(x: -10, y: -20, width: 420, height: 800)

    #expect(placement.bounds(in: container, content: content) == container)
}
