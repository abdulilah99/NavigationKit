//
//  Navigable.swift
//  Serotonin
//
//  Created by Abdulilah Imad on 2/24/24.
//

import SwiftUI

public protocol Navigable: Identifiable, Hashable, Equatable {
    associatedtype Destination: View
    associatedtype Modifier: ViewModifier
    
    var id: Self.ID { get }
    var titleKey: LocalizedStringKey { get }
    var image: Image { get }
    @ViewBuilder var destination: Destination { get }
    var modifier: Modifier { get }
    
    @available(iOS 18.0, macOS 15.0, tvOS 18.0, visionOS 2.0, *)
    var role: TabRole? { get }
}

public extension Navigable {
    var modifier: some ViewModifier { EmptyModifier() }
    
    @available(iOS 18.0, macOS 15.0, tvOS 18.0, visionOS 2.0, *)
    var role: TabRole? { nil }
}

public extension Navigable where Modifier == EmptyModifier {
    var modifier: EmptyModifier { EmptyModifier() }
}
