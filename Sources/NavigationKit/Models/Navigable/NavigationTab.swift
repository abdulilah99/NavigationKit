//
//  NavigationTab.swift
//  Serotonin
//
//  Created by Abdulilah Imad on 3/12/24.
//

import SwiftUI
import Observation

@Observable
public class NavigationTab<Page: Navigable>: Identifiable {
    let page: Page
    var path: [Page]
    
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
                .navigationDestination(for: Page.self) { navigable in
                    navigable.destination
                }
        }
        .environment(\.navigationPath, path)
        .environment(\.setNavigationPath, SetNavigationPathAction(action: { path in
            self.path = path as! [Page]
        }))
    }
}
