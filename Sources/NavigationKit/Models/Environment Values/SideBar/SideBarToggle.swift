//
//  SideBarToggle.swift
//  
//
//  Created by Abdulilah Imad on 3/12/24.
//

import SwiftUI

public struct SideBarToggleAction {
    typealias Action = () -> Void
    let action: Action
    
    func callAsFunction() {
        action()
    }
}

public extension EnvironmentValues {
    @Entry var toggleSideBar: SideBarToggleAction = .init(action: {})
}
