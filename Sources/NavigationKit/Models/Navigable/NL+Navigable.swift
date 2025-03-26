//
//  NL+Navigable.swift
//  NavigationKit
//
//  Created by Abdulilah on 20/03/2025.
//

import SwiftUI

public extension NavigationLink where Destination == Never, Label == SwiftUI.Label<Text, Image> {
     init(value: any Navigable) {
         self.init(value: value) {
             Label(title: { Text(value.titleKey) }) { value.image }
         }
     }
 }
