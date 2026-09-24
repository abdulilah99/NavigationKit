//
//  NavigationStackView.swift
//  NavigationKit
//

import SwiftUI

struct NavigationStackView<Destination: Navigable>: View {
    let destination: Destination
    @Binding var path: [Destination]

    var body: some View {
        NavigationStack(path: $path) {
            NavigationDestinationView(destination: destination, isActive: path.isEmpty)
                .navigationDestination(for: Destination.self) { destination in
                    NavigationDestinationView(destination: destination, isActive: path.last == destination)
                }
        }
    }
}
