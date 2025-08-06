//
//  NavigationView.swift
//  NavigationKit
//
//  Created by Abdulilah on 15/03/2025.
//

import SwiftUI

public struct NavigationView<Controller: NavigationController>: View {
    @Binding var controller: Controller
    
    public init(controller: Binding<Controller>) {
        self._controller = controller
    }
    
    public var body: some View {
        view
            .environment(\.navigationSelection, controller.selectedTab)
            .environment(\.setNavigationSelection, SetNavigationSelectionAction(action: { selection in
                controller.selectedTab = selection as! Controller.Tab
            }))
    }
    
    @ViewBuilder
    private var iOS17Compatible: some View {
        if controller.useCustomNavigationView {
            CustomNavigationView(tabs: controller.tabs)
        } else {
            OldTabNavigationView(tabs: controller.tabs)
        }
    }

    @available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
    private var iOS18Compatible: some View {
        TabNavigationView(tabs: controller.tabs)
    }

    @ViewBuilder
    private var view: some View {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, *) {
            iOS18Compatible
        } else {
            iOS17Compatible
        }
    }
}
