//
//  NC+Views.swift
//  Serotonin
//
//  Created by Abdulilah on 03/03/2025.
//

import SwiftUI

public extension NavigationController {
    private var selection: Binding<Destination?> {
        Binding(
            get: { self.selectedRoot },
            set: { newValue in
                if let newValue {
                    self.selectedRoot = newValue
                }
            }
        )
    }

    private var legacyView: some View {
        LegacyNavigationView(roots: roots, selection: selection)
    }
    
    @available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
    private var modernView: some View {
        TabNavigationView(roots: roots, selection: selection)
    }
    
    @ViewBuilder
    private var view: some View {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, *) {
            modernView
        } else {
            legacyView
        }
    }
    
    /// Creates NavigationKit's standard platform-adaptive navigation UI.
    ///
    /// Build custom navigation chrome directly from the controller's roots,
    /// selection, and navigation operations instead.
    func makeView() -> some View {
        view
    }
}
