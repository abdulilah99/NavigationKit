//
//  CustomNavigationView.swift
//
//
//  Created by Abdulilah Imad on 3/12/24.
//

import SwiftUI

public struct CustomNavigationView<Page: Navigable>: View {
    @Environment(\.navigationSelection) var selection
    
    @Namespace var namespace
    
    var tabs: [NavigationTab<Page>]
    
    public init(tabs: [NavigationTab<Page>]) {
        self.tabs = tabs
    }
    
    public var body: some View {
        SideBarView(tabs) {
            TabBarView(tabs) {
                ForEach(tabs) { tab in
                    ControllerView<Page>()
                        .environment(tab)
                        .opacity(selection?.hashValue != tab.page.hashValue ? 0 : 1)
                }
            }
        }
        .environment(\.serotoninNamespace, namespace)
    }
}

fileprivate struct ControllerView<Page: Navigable>: View {
    @Environment(NavigationTab<Page>.self) var tab
    
    var body: some View {
        @Bindable var tab = tab
        NavigationStack(path: $tab.path) {
            tab.page.destination
                .toolbar { SideBarToggleButton(isInSideBar: false) }
                .navigationDestination(for: Page.self) { navigable in
                    navigable.destination
                        .environment(tab)
                }
        }
    }
}

