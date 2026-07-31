//
//  NavigationController.swift
//  Serotonin
//
//  Created by Abdulilah on 26/02/2025.
//

import SwiftUI

@MainActor
public protocol NavigationController: AnyObject, Observable {
    associatedtype Destination: Navigable
    
    var selectedRoot: Destination { get set }
    func select(root: Destination)
    
    var roots: [NavigationRoot<Destination>] { get set }
    func navigate(to destination: Destination, on root: Destination?)
    
    subscript(root: Destination) -> [Destination] { get set }
}
