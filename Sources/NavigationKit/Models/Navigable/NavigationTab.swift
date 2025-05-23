//
//  NavigationTab.swift
//  Serotonin
//
//  Created by Abdulilah Imad on 3/12/24.
//

import SwiftUI
import Observation

@Observable
@MainActor
public class NavigationTab<Page: Navigable>: Identifiable {
    public let page: Page
    public var path: [Page]
    
    public init(page: Page, path: [Page] = []) {
        self.page = page
        self.path = path
    }
    
    var pathBinding: Binding<[Page]> {
        .init(get: { self.path }) { newValue in
            self.path = newValue
        }
    }
    
    @ViewBuilder
    public var content: some View {
        NavigationStack(path: pathBinding) {
            page.destination
                .modifier(page.modifier)
                .navigationDestination(for: Page.self) { navigable in
                    navigable.destination
                        .modifier(navigable.modifier)
                }
        }
        .environment(\.navigationPath, path)
        .environment(\.setNavigationPath, SetNavigationPathAction(action: { path in
            self.path = path as! [Page]
        }))
    }
}
