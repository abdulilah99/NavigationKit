//
//  ContentView.swift
//  Example App
//
//  Created by Abdulilah on 23/03/2025.
//

import SwiftUI
import NavigationKit

struct ContentView: View {
    @Environment(NavigationController.self) var navigationController
    
    var body: some View {
        navigationController.makeView()
    }
}

#Preview {
    ContentView()
        .environment(NavigationController())
}
