//
//  ViewModifier+Sheets.swift
//  Serotonin
//
//  Created by Abdulilah on 27/02/2025.
//

import SwiftUI

private struct SheetsPresenter<M: Modal>: ViewModifier {
    @Binding var items: [M]
    var currentIndex: Int = 0
    var isFullScreen: Bool
    
    @State var currentItem: M? = nil
    
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
    func nextSheet(for item: M?) -> some View {
        if let item {
            if currentIndex < items.count {
                item.destination
                    .modifier(item.modifier)
                    .sheetsPresenter(items: $items, currentIndex: currentIndex + 1)
            } else {
                item.destination
                    .modifier(item.modifier)
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
    func sheetsPresenter<M: Modal>(items: Binding<[M]>, currentIndex: Int) -> some View {
        modifier(SheetsPresenter(items: items, currentIndex: currentIndex, isFullScreen: currentIndex < items.count ? items.wrappedValue[currentIndex].isFullScreen : false))
    }
    
    public func sheets<M: Modal>(items: Binding<[M]>) -> some View {
        sheetsPresenter(items: items, currentIndex: 0)
    }
}

private struct LegacySheetsPresenter<M: Modal>: ViewModifier {
    @Binding var items: [M]
    
    var item: Binding<M?> {
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
                .sheet(item: item, onDismiss: item.wrappedValue?.onDismiss) { item in
                    item.destination
                        .modifier(item.modifier)
                        .presentationCompactAdaptation(.fullScreenCover)
                }
        } else {
            content
                .sheet(item: item, onDismiss: item.wrappedValue?.onDismiss) { item in
                    item.destination
                        .modifier(item.modifier)
                }
        }
    }
}

private extension View {
    func legacySheets<M: Modal>(items: Binding<[M]>) -> some View {
        modifier(LegacySheetsPresenter(items: items))
    }
}
