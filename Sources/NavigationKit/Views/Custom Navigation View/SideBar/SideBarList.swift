//
//  SideBarList.swift
//  
//
//  Created by Abdulilah Imad on 7/3/24.
//

import SwiftUI

struct SideBarList<Page: Navigable>: View {
    @Environment(\.isSideBarPresented) private var isSideBarPresented
    @Environment(\.toggleSideBar) private var toggleSideBar
    @Environment(\.sideBarTitle) private var sideBarTitle
    
    var tabs: [NavigationTab<Page>]
    
    init(_ tabs: [NavigationTab<Page>]) {
        self.tabs = tabs
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(tabs) { tab in
                    if tab.page.placement.isInSideBar {
                        SideBarButton(page: tab.page)
                            .environment(\.navigationPath, tab.path)
                            .environment(\.setNavigationPath, SetNavigationPathAction(action: { path in
                                tab.path = path as! [Page]
                            }))
                    }
                }
            }
            .listStyle(.plain)
            .background(Color(.secondarySystemGroupedBackground))
            .navigationTitle(sideBarTitle)
            .toolbar { SideBarToggleButton(isInSideBar: true) }
        }
        .frame(maxHeight: .infinity)
        .frame(width: 320)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
