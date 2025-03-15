//
//  Navigable.swift
//  Serotonin
//
//  Created by Abdulilah Imad on 2/24/24.
//

import SwiftUI

public protocol Navigable: Identifiable, Hashable, Equatable {
    associatedtype Destination: View
    
    var id: Self.ID { get }
    var titleKey: LocalizedStringKey { get }
    var systemImage: String { get }
    @ViewBuilder var destination: Destination { get }
    
    var placement: BarPlacement { get }
    
    @available(iOS 18.0, macOS 15.0, tvOS 18.0, *)
    var role: TabRole? { get }
}

public extension Navigable {
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
