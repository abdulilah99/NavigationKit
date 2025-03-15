//
//  NC+Views.swift
//  Serotonin
//
//  Created by Abdulilah on 03/03/2025.
//

import SwiftUI

public extension NavigationController {
    private var sheetsBinding: Binding<[Card]> {
        Binding(get: {
            self.sheets
        }) { newValue in
            self.sheets = newValue
        }
    }
    
    @ViewBuilder
    private var iOS17Compatible: some View {
        if useCustomNavigationView {
            CustomNavigationView(tabs: tabs)
        } else {
            OldTabNavigationView(tabs: tabs)
        }
    }
    
    @available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
    private var iOS18Compatible: some View {
        TabNavigationView(tabs: tabs)
    }
    
    @ViewBuilder
    private var view: some View {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, *) {
            iOS18Compatible
        } else {
            iOS17Compatible
        }
    }
    
    func makeView() -> some View {
        view
            .sheets(items: sheetsBinding)
            .environment(\.navigationSelection, selectedTab)
            .environment(\.setNavigationSelection, SetNavigationSelectionAction(action: { selection in
                self.selectedTab = selection as! Tab
            }))
    }
}
