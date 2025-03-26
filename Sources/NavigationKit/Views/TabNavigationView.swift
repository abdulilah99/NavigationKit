//
//  TabNavigationView.swift
//  Serotonin
//
//  Created by Abdulilah on 28/02/2025.
//

import SwiftUI

@available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
struct TabNavigationView<Page: Navigable>: View {
    @Environment(\.navigationSelection) var navigationSelection
    @Environment(\.setNavigationSelection) var setNavigationSelection
    
    @Namespace var namespace
    
    var tabs: [NavigationTab<Page>]
    
    public init(tabs: [NavigationTab<Page>]) {
        self.tabs = tabs
    }
    
    var selection: Binding<Page?> {
        Binding(get: { navigationSelection as? Page }) { newValue in
            if let newValue {
                setNavigationSelection.callAsFunction(selection: newValue)
            }
        }
    }
    
    public var body: some View {
        TabView(selection: selection) {
            ForEach(tabs) { tab in
                Tab(value: tab.page, role: tab.page.role, content: { tab.content }) {
                    Label(title: { Text(tab.page.titleKey) }) { tab.page.image }
                }
                .tabPlacement(!tab.page.placement.isInTabBar ? .sidebarOnly : .automatic)
                #if os(iOS) || os(macOS)
                .defaultVisibility(tab.page.placement.tabBarVisibility, for: .tabBar)
                #endif
                #if os(iOS)
                .defaultVisibility(tab.page.placement.sideBarVisibility, for: .sidebar)
                #endif
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .environment(\.serotoninNamespace, namespace)
    }
}
