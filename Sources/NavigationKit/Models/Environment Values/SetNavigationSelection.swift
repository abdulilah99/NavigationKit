//
//  SetNavigationSelection.swift
//  Serotonin
//
//  Created by Abdulilah Imad on 3/12/24.
//

import SwiftUI

public struct SetNavigationSelectionAction {
    typealias Action = (any Navigable) -> Void
    let action: Action
    
    func callAsFunction(selection: any Navigable) {
        action(selection)
    }
}

public extension EnvironmentValues {
    @Entry var setNavigationSelection: SetNavigationSelectionAction = .init(action: { _ in })
}
