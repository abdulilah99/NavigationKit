//
//  SideBarButton.swift
//
//
//  Created by Abdulilah Imad on 7/9/24.
//

import SwiftUI

struct SideBarButton<Page: Navigable>: View {
    @Environment(\.navigationSelection) var navigationSelection
    @Environment(\.setNavigationSelection) var setNavigationSelection
    //@Environment(\.navigationStack) var navigationStack
    @Environment(\.setNavigationPath) var setNavigationStack
    
    let page: Page
    
    var isActive: Bool {
        navigationSelection?.id as? Page.ID == page.id
    }
    
    @State var isAnimating: Bool = false
    
    var body: some View {
        Button(action: {
            print(isActive)
            isAnimating.toggle()
            if isActive {
                setNavigationStack.callAsFunction(stack: [])
            } else {
                setNavigationSelection.callAsFunction(selection: page)
            }
        }) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    //.fill(Color(.systemGroupedBackground))
                    .fill(Color(red: 242, green: 242, blue: 247))
                    .opacity(isActive ? 1 : 0.0001)
                
                Label(title: { Text(page.titleKey) }) { page.image }
                    //.symbolEffect(.bounce, options: .nonRepeating, value: isAnimating)
                    .padding(.horizontal)
            }
            .frame(height: 48)
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        .listRowBackground(Color.clear)
        #if os(iOS) || os(macOS)
        .listRowSeparator(.hidden)
        #endif
    }
}

