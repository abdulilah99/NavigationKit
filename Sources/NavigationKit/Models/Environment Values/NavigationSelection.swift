//
//  NavigationSelection.swift
//  Serotonin
//
//  Created by Abdulilah Imad on 3/12/24.
//

import SwiftUI

public extension EnvironmentValues {
    @Entry var navigationSelection: (any Navigable)? = nil
}
