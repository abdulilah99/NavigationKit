//
//  Sheet.swift
//  Example App
//
//  Created by Abdulilah on 23/03/2025.
//

import SwiftUI
import ModalKit

enum Sheet: Modal {
    case login
    
    var id: Self { self }
    
    var destination: some View {
        switch self {
        case .login: Color.red
        }
    }
}
