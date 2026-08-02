//
//  NavigationStackHost.swift
//  NavigationKit
//

import SwiftUI

struct NavigationStackHost<Destination: Navigable>: View {
    let destination: Destination
    @Binding var path: [Destination]

    var body: some View {
        NavigationStack(path: $path) {
            destination.content
                .navigationDestination(for: Destination.self) { destination in
                    destination.content
                }
        }
    }
}
