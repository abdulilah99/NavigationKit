//
//  SetNavigationStack.swift
//  Serotonin
//
//  Created by Abdulilah Imad on 3/12/24.
//

import SwiftUI

public struct SetNavigationPathAction {
    typealias Action = ([any Navigable]) -> Void
    let action: Action
    
    func callAsFunction(stack: [any Navigable]) {
        action(stack)
    }
}

public extension EnvironmentValues {
    @Entry var setNavigationPath: SetNavigationPathAction = .init(action: { _ in })
}
