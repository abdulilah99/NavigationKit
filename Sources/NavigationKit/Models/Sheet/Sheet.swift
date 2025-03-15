//
//  Sheet.swift
//  Serotonin
//
//  Created by Abdulilah on 27/02/2025.
//

import SwiftUI

public protocol Sheet: Navigable {
    var isFullScreen: Bool { get }
    func onDismiss()
}

public extension Sheet {
    var titleKey: LocalizedStringKey { "Sheet" }
    var systemImage: String { "" }
    var placement: BarPlacement { .none }
    var isFullScreen: Bool { false }
    func onDismiss() { }
}
