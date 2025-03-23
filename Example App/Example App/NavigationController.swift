//
//  NavigationController.swift
//  Example App
//
//  Created by Abdulilah on 23/03/2025.
//

import NavigationKit
import SwiftUI
import Observation

@Observable
class NavigationController: NavigationKit.NavigationController {
    var selectedTab: Page = .home
    var tabs: [NavigationTab] = [.init(page: Page.home), .init(page: .settings)]
    var sheets: [Sheet] = []
}
