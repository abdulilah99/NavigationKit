//
//  ViewModifier+Cover.swift
//  Serotonin
//
//  Created by Abdulilah on 05/03/2025.
//

import SwiftUI

private struct Cover<Destination: View>: ViewModifier {
    @Binding var isPresented: Bool
    var isFullscreen: Bool
    var onDismiss: (() -> Void)?
    var destination: () -> Destination
    
    func body(content: Content) -> some View {
        if isFullscreen {
            content
                .fullScreenCover(isPresented: $isPresented, onDismiss: onDismiss, content: destination)
        } else {
            content
                .sheet(isPresented: $isPresented, onDismiss: onDismiss, content: destination)
        }
    }
}

public extension View {
    func cover<Destination: View>(isPresented: Binding<Bool>, isFullScreen: Bool? = false, onDismiss: (() -> Void)? = nil, @ViewBuilder destination: @escaping () -> Destination) -> some View {
        modifier(Cover(isPresented: isPresented, isFullscreen: isFullScreen ?? false, onDismiss: onDismiss, destination: destination))
    }
}
