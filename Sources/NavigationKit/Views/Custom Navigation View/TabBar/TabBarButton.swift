//
//  TabBarButton.swift
//
//
//  Created by Abdulilah Imad on 2/24/24.
//

import SwiftUI

struct TabBarButton<Page: Navigable>: View {
    @Environment(\.navigationSelection) private var navigationSelection
    @Environment(\.setNavigationSelection) private var setNavigationSelection
    @Environment(\.setNavigationPath) private var setNavigationPath
    
    let page: Page
    
    var isActive: Bool {
        (navigationSelection as? Page) == page
    }
    
    var body: some View {
        Button(action: {
            if isActive {
                setNavigationPath.callAsFunction(stack: [])
            } else {
                setNavigationSelection.callAsFunction(selection: page)
            }
        }) {
            VStack(spacing: 2) {
                page.image
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
