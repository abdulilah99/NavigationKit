//
//  NC+Hosting.swift
//  NavigationKit
//
//  Created by Abdulilah on 03/03/2025.
//

import SwiftUI

public extension NavigationController {
    /// Creates NavigationKit's standard platform-adaptive navigation UI.
    ///
    /// Build custom navigation chrome directly from the controller's roots,
    /// selection, and navigation operations instead.
    func makeView() -> some View {
        NavigationHost(navigation: self)
            .navigationPresentations(for: self)
    }
}
