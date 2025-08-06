//
//  Modal.swift
//  Serotonin
//
//  Created by Abdulilah on 27/02/2025.
//

import SwiftUI

public protocol Modal: Identifiable, Hashable, Equatable {
    associatedtype Destination: View
    associatedtype Modifier: ViewModifier
    
    var id: Self.ID { get }
    var titleKey: LocalizedStringKey { get }
    var image: Image { get }
    @ViewBuilder var destination: Destination { get }
    var modifier: Modifier { get }
    
    var isFullScreen: Bool { get }
    func onDismiss()
}

public extension Modal {
    var titleKey: LocalizedStringKey { "Sheet" }
    var image: Image { Image(systemName: "") }
    var isFullScreen: Bool { false }
    func onDismiss() { }
}

public extension Modal where Modifier == EmptyModifier {
    var modifier: EmptyModifier { EmptyModifier() }
}
