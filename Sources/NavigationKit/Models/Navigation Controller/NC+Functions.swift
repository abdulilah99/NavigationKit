//
//  NC+Functions.swift
//  Serotonin
//
//  Created by Abdulilah on 03/03/2025.
//

import Foundation

public extension NavigationController {
    func select(root: Destination) {
        guard roots.contains(where: { $0.destination == root }) else {
            return
        }

        selectedRoot = root
    }
    
    func navigate(
        to destination: Destination,
        on root: Destination? = nil
    ) {
        let targetRoot = root ?? selectedRoot
        
        guard let existingStack = roots.first(
            where: { $0.destination == targetRoot }
        ) else {
            return
        }

        if let index = existingStack.path.firstIndex(of: destination) {
            let removalIndex = index + 1
            existingStack.path.removeSubrange(removalIndex..<existingStack.path.count)
        } else {
            existingStack.path.append(destination)
        }
        
        selectedRoot = targetRoot
    }
    
    subscript(root: Destination) -> [Destination] {
        get {
            roots.first(where: { $0.destination == root })?.path ?? []
        }
        set {
            roots.first(where: { $0.destination == root })?.path = newValue
        }
    }
}
