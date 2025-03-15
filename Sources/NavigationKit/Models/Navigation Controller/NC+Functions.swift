//
//  NC+Functions.swift
//  Serotonin
//
//  Created by Abdulilah on 03/03/2025.
//

import Foundation

public extension NavigationController {
    func select(tab: Tab) {
        selectedTab = tab
    }
    
    func navigate(to page: Tab, on tab: Tab? = nil) {
        let targetTab = tab ?? selectedTab
        
        if let existingStack = tabs.first(where: { $0.page == targetTab }) {
            if let index = existingStack.path.firstIndex(where: { $0.hashValue == page.hashValue }) {
                let removalIndex = index + 1
                existingStack.path.removeSubrange(removalIndex..<existingStack.path.count)
            } else {
                existingStack.path.append(page)
            }
        } else {
            tabs.append(NavigationTab(page: targetTab, path: [page]))
        }
        
        selectedTab = targetTab
    }
    
    func present(sheet: Card) {
        if let index = sheets.firstIndex(of: sheet) {
            let removalIndex = index + 1
            sheets.removeSubrange(removalIndex..<sheets.count)
        } else {
            sheets.append(sheet)
        }
    }
}
