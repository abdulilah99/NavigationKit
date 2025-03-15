//
//  TabBarView.swift
//
//
//  Created by Abdulilah Imad on 2/24/24.
//

import SwiftUI

struct TabBarView<Content: View, Page: Navigable>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var tabs: [NavigationTab<Page>]
    var content: Content
    
    init(_ tabs: [NavigationTab<Page>], @ViewBuilder content: () -> Content) {
        self.tabs = tabs
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            content
            
            TabBarList(tabs)
                .ignoresSafeArea(.keyboard)
                .opacity(horizontalSizeClass != .compact ? 0 : 1)
        }
    }
}
