//
//  ViewModifier+Sheets.swift
//  Serotonin
//
//  Created by Abdulilah on 27/02/2025.
//

import SwiftUI

private struct SheetsPresenter<S: Sheet>: ViewModifier {
    @Binding var items: [S]
    var currentIndex: Int = 0
    var isFullScreen: Bool
    
    @State var currentItem: S? = nil
    
    var currentItemBinding: Binding<Bool> {
        .init(get: { currentItem != nil }) { newValue in
            if currentIndex < items.count {
                if !newValue {
                    items.remove(at: currentIndex)
                    currentItem = nil
                } else {
                    currentItem = items[currentIndex]
                }
            } else {
                currentItem = nil
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .cover(isPresented: currentItemBinding, isFullScreen: isFullScreen) {
                nextSheet(for: currentItem)
            }
            .onChange(of: items) { _, newValue in
                updateItem()
            }
            .onAppear(perform: updateItem)
    }
    
    @ViewBuilder
    func nextSheet(for item: S?) -> some View {
        if let item {
            if currentIndex < items.count {
                item.destination
                    .sheetsPresenter(items: $items, currentIndex: currentIndex + 1)
            } else {
                item.destination
            }
        }
    }
    
    func updateItem() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            if currentIndex < items.count {
                currentItem = items[currentIndex]
            } else {
                currentItemBinding.wrappedValue = false
            }
        }
    }
}

extension View {
    func sheetsPresenter<S: Sheet>(items: Binding<[S]>, currentIndex: Int) -> some View {
        modifier(SheetsPresenter(items: items, currentIndex: currentIndex, isFullScreen: currentIndex < items.count ? items.wrappedValue[currentIndex].isFullScreen : false))
    }
    
    public func sheets<S: Sheet>(items: Binding<[S]>) -> some View {
        sheetsPresenter(items: items, currentIndex: 0)
    }
}

private struct LegacySheetsPresenter<S: Sheet>: ViewModifier {
    @Binding var items: [S]
    
    var item: Binding<S?> {
        Binding(get: {
            return items.last
        }) { newValue in
            if newValue == nil {
                items.removeLast()
            }
        }
    }
    
    func body(content: Content) -> some View {
        if item.wrappedValue?.isFullScreen ?? false {
            content
                .fullScreenCover(item: item, onDismiss: item.wrappedValue?.onDismiss) { item in
                    item.destination
                }
        } else {
            content
                .sheet(item: item, onDismiss: item.wrappedValue?.onDismiss) { item in
                    item.destination
                }
        }
    }
}

private extension View {
    func legacySheets<S: Sheet>(items: Binding<[S]>) -> some View {
        modifier(LegacySheetsPresenter(items: items))
    }
}
