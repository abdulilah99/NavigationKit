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
                Tab(tab.page.titleKey, systemImage: tab.page.systemImage, value: tab.page, role: tab.page.role) {
                    tab.content
                }
                .tabPlacement(.automatic)
                .defaultVisibility(tab.page.placement.sideBarVisibility, for: .sidebar)
                .defaultVisibility(tab.page.placement.tabBarVisibility, for: .tabBar)
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .defaultAdaptableTabBarPlacement(.sidebar)
        .environment(\.serotoninNamespace, namespace)
    }
}
