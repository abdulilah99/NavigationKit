//
//  TabBarList.swift
//  Serotonin
//
//  Created by Abdulilah Imad on 2/24/24.
//

import SwiftUI

struct TabBarList<Page: Navigable>: View {
    var tabs: [NavigationTab<Page>]
    
    init(_ tabs: [NavigationTab<Page>]) {
        self.tabs = tabs
    }
    
    var body: some View {
        VStack(spacing: 7) {
            Divider()
            
            HStack(spacing: 50) {
                ForEach(tabs) { tab in
                    if tab.page.placement.isInTabBar {
                        TabBarButton(page: tab.page)
                            .environment(\.navigationPath, tab.path)
                            .environment(\.setNavigationPath, SetNavigationPathAction(action: { path in
                                tab.path = path as! [Page]
                            }))
                    }
                }
            }.padding(.horizontal, 25)
        }
        .frame(height: 50)
        .background {
            Rectangle()
                .fill(.thinMaterial)
                .ignoresSafeArea(edges: .all)
        }
    }
}
