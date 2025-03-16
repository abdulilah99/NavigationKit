//
//  NavigationController.swift
//  Serotonin
//
//  Created by Abdulilah on 26/02/2025.
//

import SwiftUI

@MainActor
public protocol NavigationController: AnyObject, Observable {
    associatedtype Tab: Navigable
    associatedtype Card: Sheet
    
    var selectedTab: Tab { get set }
    func select(tab: Tab)
    
    var tabs: [NavigationTab<Tab>] { get set }
    func navigate(to page: Tab, on tab: Tab?)
    
    var sheets: [Card] { get set }
    func present(sheet: Card)
    
    var useCustomNavigationView: Bool { get }
    
    subscript(tab: Tab) -> [Tab] { get set }
}
