//
//  MC+Functions.swift
//  NavigationKit
//
//  Created by Abdulilah on 06/08/2025.
//

import Foundation

public extension ModalController {
    func present(sheet: Sheet) {
        if let index = sheets.firstIndex(of: sheet) {
            let removalIndex = index + 1
            sheets.removeSubrange(removalIndex..<sheets.count)
        } else {
            sheets.append(sheet)
        }
    }
}
