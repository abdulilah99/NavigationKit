//
//  ModalController.swift
//  NavigationKit
//
//  Created by Abdulilah on 06/08/2025.
//

import SwiftUI

@MainActor
public protocol ModalController: AnyObject, Observable {
    associatedtype Sheet: Modal
    
    var sheets: [Sheet] { get set }
    func present(sheet: Sheet)
}
