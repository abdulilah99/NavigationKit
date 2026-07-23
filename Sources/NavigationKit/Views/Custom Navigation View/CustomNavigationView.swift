//
//  CustomNavigationView.swift
//
//
//  Created by Abdulilah Imad on 3/12/24.
//

import SwiftUI

public struct CustomNavigationView<Page: Navigable>: View {
    @Environment(\.navigationSelection) private var selection
    
    @Namespace private var namespace
    
    var tabs: [NavigationTab<Page>]
    
    public init(tabs: [NavigationTab<Page>]) {
        self.tabs = tabs
    }
    
    public var body: some View {
        SideBarView(tabs) {
            TabBarView(tabs) {
                ForEach(tabs) { tab in
                    let isSelected = (selection as? Page) == tab.page

                    ControllerView<Page>()
                        .environment(tab)
                        .opacity(isSelected ? 1 : 0)
                        .allowsHitTesting(isSelected)
                        .disabled(!isSelected)
                        .accessibilityHidden(!isSelected)
                }
            }
        }
        .environment(\.serotoninNamespace, namespace)
    }
}

fileprivate struct ControllerView<Page: Navigable>: View {
    @Environment(NavigationTab<Page>.self) private var tab
    
    var body: some View {
        @Bindable var tab = tab
        NavigationStack(path: $tab.path) {
            tab.page.destination
                .modifier(tab.page.modifier)
                .toolbar { SideBarToggleButton(isInSideBar: false) }
                .navigationDestination(for: Page.self) { navigable in
                    navigable.destination
                        .modifier(navigable.modifier)
                        .environment(tab)
                }
        }
    }
}
