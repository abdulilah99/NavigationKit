//
//  NC+Functions.swift
//  Serotonin
//
//  Created by Abdulilah on 03/03/2025.
//

public extension NavigationController {
    func select(root: Destination) {
        updateSelection(to: root)
    }
    
    func navigate(
        to destination: Destination,
        on root: Destination? = nil
    ) {
        let targetRoot = root ?? selectedRoot
        
        guard let existingStack = self.root(for: targetRoot) else {
            return
        }

        if let index = existingStack.path.firstIndex(of: destination) {
            let removalIndex = index + 1
            existingStack.path.removeSubrange(removalIndex..<existingStack.path.count)
        } else {
            existingStack.path.append(destination)
        }
        
        updateSelection(to: targetRoot)
    }
    
    subscript(root: Destination) -> [Destination] {
        get {
            self.root(for: root)?.path ?? []
        }
        set {
            self.root(for: root)?.path = newValue
        }
    }
}
