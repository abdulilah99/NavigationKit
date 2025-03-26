//
//  Page.swift
//  Example App
//
//  Created by Abdulilah on 23/03/2025.
//

import SwiftUI
import NavigationKit

enum Page: Navigable {
    case home
    case settings
    
    var id: Self { self }
    
    var titleKey: LocalizedStringKey {
        switch self {
        case .home: "page.home.titleKey"
        case .settings: "page.settings.titleKey"
        }
    }
    
    var image: Image {
        var name: String = ""
        
        switch self {
        case .home: name = "house"
        case .settings: name = "gear"
        }
        
        return Image(systemName: name)
    }
    
    var destination: some View {
        switch self {
        case .home: Color.red
        case .settings: Color.teal
        }
    }
    
    var placement: BarPlacement {
        switch self {
        case .home: .tab
        case .settings: .all
        }
    }
}
