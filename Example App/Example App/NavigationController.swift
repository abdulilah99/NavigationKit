//
//  NavigationController.swift
//  Example App
//
//  Created by Abdulilah on 23/03/2025.
//

import SwiftUI
import Observation
import NavigationKit
import ModalKit

@Observable
class Router: NavigationController, ModalController {
    var selectedTab: Page = .home
    var tabs: [NavigationTab] = [.init(page: Page.home), .init(page: .settings)]
    var sheets: [Sheet] = []
}
