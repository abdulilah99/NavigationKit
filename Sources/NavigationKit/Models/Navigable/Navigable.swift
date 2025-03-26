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
    
    var placement: BarPlacement { get }
    
    @available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
    var role: TabRole? { get }
}

public extension Navigable {
    var modifier: some ViewModifier { EmptyModifier() }
    
    var placement: BarPlacement { .all }
    
    @available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
    var role: TabRole? { nil }
}

public enum BarPlacement: Hashable, Codable {
    case all, side, tab, none
    
    var isInSideBar: Bool { [.all, .side].contains(self) }
    
    var isInTabBar: Bool { [.all, .tab].contains(self) }
    
    var sideBarVisibility: Visibility { isInSideBar ? .visible : .hidden }
    
    var tabBarVisibility: Visibility { isInTabBar ? .visible : .hidden }
}
