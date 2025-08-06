//
//  ContentView.swift
//  Example App
//
//  Created by Abdulilah on 23/03/2025.
//

import SwiftUI
import NavigationKit
import ModalKit

struct ContentView: View {
    @Environment(Router.self) var router
    
    var body: some View {
        @Bindable var router = router
        router.makeView()
            .sheets(items: $router.sheets)
    }
}

#Preview {
    ContentView()
        .environment(Router())
}
