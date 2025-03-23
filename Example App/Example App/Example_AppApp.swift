//
//  Example_AppApp.swift
//  Example App
//
//  Created by Abdulilah on 23/03/2025.
//

import SwiftUI

@main
struct Example_AppApp: App {
    @State var navigationController = NavigationController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(navigationController)
        }
    }
}
