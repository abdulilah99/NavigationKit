//
//  Navigable.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 2/24/24.
//

import SwiftUI

public protocol Navigable: Identifiable, Hashable {
    associatedtype Content: View

    var titleKey: LocalizedStringKey { get }
    var icon: Image { get }
    @ViewBuilder var content: Content { get }
}
