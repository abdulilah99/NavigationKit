//
//  Example_AppApp.swift
//  Example App
//
//  Created by Abdulilah on 23/03/2025.
//

import SwiftUI
import NavigationKit

@main
struct Example_AppApp: App {
    @State private var navigation = makeExampleNavigationController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(navigation)
        }
    }
}
