//
//  TabBarButton.swift
//
//
//  Created by Abdulilah Imad on 2/24/24.
//

import SwiftUI

struct TabBarButton<Page: Navigable>: View {
    @Environment(\.navigationSelection) var navigationSelection
    @Environment(\.setNavigationSelection) var setNavigationSelection
    @Environment(\.setNavigationPath) var setNavigationPath
    
    let page: Page
    
    var isActive: Bool {
        navigationSelection?.id as? Page.ID == page.id
    }
    
    @State var isAnimating: Bool = false
    
    var body: some View {
        Button(action: {
            isAnimating.toggle()
            if isActive {
                setNavigationPath.callAsFunction(stack: [])
            } else {
                setNavigationSelection.callAsFunction(selection: page)
            }
        }) {
            VStack(spacing: 2) {
                Image(systemName: page.systemImage)
                    //.symbolEffect(.bounce.byLayer, options: .nonRepeating, value: isAnimating)
                    .symbolVariant(.fill)
                    .font(.system(size: 24))
                    .frame(height: 26)
                
                Text(page.titleKey)
                    .font(.system(size: 11))
                    .lineLimit(1)
            }
            .frame(width: 58)
            .foregroundColor(isActive ? .accentColor : .primary.opacity(0.5))
            .labelsHidden()
        }
    }
}
