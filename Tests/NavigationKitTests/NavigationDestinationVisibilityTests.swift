#if os(macOS)
import AppKit
import SwiftUI
import Testing
@testable import NavigationKit

@MainActor
@Suite(.serialized)
struct NavigationDestinationVisibilityTests {
    @Test
    func retainedRootsKeepEqualDestinationsIndependent() async throws {
        let navigation = NavigationController<VisibilityPage>(roots: [
            NavigationRoot(destination: .home, path: [.details]),
            NavigationRoot(destination: .library, path: [.details]),
        ])
        let probe = VisibilityProbe()
        let content = HStack {
            navigation.roots[0].content(for: navigation)
                .environment(\.visibilityContainer, "home")
            navigation.roots[1].content(for: navigation)
                .environment(\.visibilityContainer, "library")
        }.environment(probe)

        try await withHost(content) {
            try await waitFor { probe.values["home:details"] == true && probe.values["library:details"] == false }
            navigation.select(root: .library)
            try await waitFor { probe.values["home:details"] == false && probe.values["library:details"] == true }
            navigation.present(.home)
            try await waitFor { probe.values["library:details"] == false }
            navigation.dismissPresentation()
            try await waitFor { probe.values["library:details"] == true }
            navigation.navigateBack()
            try await waitFor { probe.values["library:library"] == true }
        }
    }

    @Test
    func repeatedModalDestinationsUseOccurrenceIdentity() async throws {
        let navigation = NavigationController<VisibilityPage>(roots: [NavigationRoot(destination: .home)])
        let first = try #require(navigation.present(.details))
        let second = try #require(navigation.present(.details))
        let probe = VisibilityProbe()
        let content = HStack {
            ForEach([first, second]) { presentation in
                NavigationPresentationView(navigation: navigation, presentation: presentation, index: 2)
                    .environment(\.visibilityContainer, presentation.id.uuidString)
            }
        }.environment(probe)
        let firstKey = "\(first.id):details"
        let secondKey = "\(second.id):details"

        try await withHost(content) {
            try await waitFor { probe.values == [firstKey: false, secondKey: true] }
            navigation.dismissPresentation(id: second.id)
            try await waitFor { probe.values == [firstKey: true, secondKey: false] }
        }
    }

    @Test
    func standaloneStacksDeriveVisibilityWithoutAController() async throws {
        let root = NavigationRoot(destination: VisibilityPage.home)
        let probe = VisibilityProbe()
        let content = root.content
            .environment(probe)
            .environment(\.visibilityContainer, "standalone")

        try await withHost(content) {
            try await waitFor { probe.values["standalone:home"] == true }
            root.path = [.details]
            try await waitFor {
                probe.values["standalone:home"] == false && probe.values["standalone:details"] == true
            }
            root.path = []
            try await waitFor { probe.values["standalone:home"] == true }
            try await waitFor { probe.modifierValues == probe.values }
        }
    }

    @Test
    func modalPathsShareVisibilityWithDestinationModifiers() async throws {
        let navigation = NavigationController<VisibilityPage>(roots: [NavigationRoot(destination: .home)])
        let presentation = try #require(navigation.present(.library))
        let probe = VisibilityProbe()
        let content = HStack {
            navigation.roots[0].content(for: navigation)
                .environment(\.visibilityContainer, "root")
            NavigationPresentationView(navigation: navigation, presentation: presentation, index: 2)
                .environment(\.visibilityContainer, "modal")
        }.environment(probe)

        try await withHost(content) {
            try await waitFor {
                probe.values["root:home"] == false && probe.values["modal:library"] == true &&
                probe.modifierValues == probe.values
            }
            navigation.navigate(to: .details, in: presentation.id)
            try await waitFor {
                probe.values["root:home"] == false && probe.values["modal:library"] == false &&
                probe.values["modal:details"] == true && probe.modifierValues == probe.values
            }
            navigation.returnToRoot(in: presentation.id)
            try await waitFor {
                probe.values["modal:library"] == true && probe.modifierValues == probe.values
            }
            navigation.dismissPresentation()
            try await waitFor {
                probe.values["root:home"] == true && probe.values["modal:library"] == false &&
                probe.modifierValues == probe.values
            }
        }
    }

    private func withHost<Content: View>(_ content: Content, verify: () async throws -> Void) async throws {
        _ = NSApplication.shared
        let window = NSWindow(contentRect: CGRect(x: 0, y: 0, width: 800, height: 600),
                              styleMask: .borderless, backing: .buffered, defer: false)
        window.contentView = NSHostingView(rootView: content.transaction { $0.disablesAnimations = true })
        window.orderFront(nil)
        defer { window.orderOut(nil); window.contentView = nil }
        try await verify()
    }

    private func waitFor(_ predicate: () -> Bool) async throws {
        let deadline = ContinuousClock.now.advanced(by: .seconds(3))
        while !predicate(), ContinuousClock.now < deadline {
            try await Task.sleep(for: .milliseconds(20))
        }
        #expect(predicate())
    }
}

@MainActor
@Observable
private final class VisibilityProbe {
    var values: [String: Bool] = [:]
    var modifierValues: [String: Bool] = [:]
}

private extension EnvironmentValues {
    @Entry var visibilityContainer = ""
}

private enum VisibilityPage: Navigable {
    case home, library, details

    var id: Self { self }
    var titleKey: LocalizedStringKey { "Visibility" }
    var icon: Image { Image(systemName: "circle") }
    var content: some View { VisibilityContent(page: self) }
    var modifier: some ViewModifier { VisibilityModifier(page: self) }
}

private struct VisibilityContent: View {
    let page: VisibilityPage

    @Environment(VisibilityProbe.self) private var probe
    @Environment(\.visibilityContainer) private var container
    @Environment(\.isNavigationDestinationVisible) private var isVisible

    var body: some View {
        Color.clear.onChange(of: isVisible, initial: true) { _, value in
            probe.values["\(container):\(page)"] = value
        }
    }
}

private struct VisibilityModifier: ViewModifier {
    let page: VisibilityPage

    @Environment(VisibilityProbe.self) private var probe
    @Environment(\.visibilityContainer) private var container
    @Environment(\.isNavigationDestinationVisible) private var isVisible

    func body(content: Content) -> some View {
        content.onChange(of: isVisible, initial: true) { _, value in
            probe.modifierValues["\(container):\(page)"] = value
        }
    }
}
#endif
