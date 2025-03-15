//
//  OldTabNavigationView.swift
//  Serotonin
//
//  Created by Abdulilah on 03/03/2025.
//

import SwiftUI

struct OldTabNavigationView<Page: Navigable>: View {
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
                tab.content
                    .tag(tab.page)
                    .tabItem {
                        Label(tab.page.titleKey, systemImage: tab.page.systemImage)
                    }
            }
        }
        .environment(\.serotoninNamespace, namespace)
    }
}
