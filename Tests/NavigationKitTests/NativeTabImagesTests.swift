//
//  NativeTabImagesTests.swift
//  NavigationKit
//
//  Created by Abdulilah Imad on 31/10/2026.
//

#if os(iOS)
import SwiftUI
import Testing
import UIKit
@testable import NavigationKit

@MainActor
@Suite struct NativeTabImagesTests {
    @Test func pairsCustomArtworkForUnvisitedAndSidebarOnlyTabs() throws {
        guard #available(iOS 26.1, *) else { return }
        let (tabs, bridge, normal, selected) = fixture()
        tabs.tabs[1].preferredPlacement = .sidebarOnly
        var environment = EnvironmentValues()
        environment.displayScale = 3

        bridge.update(pairs: Array(repeating: .init(icon: Image(uiImage: normal), selectedIcon: Image(uiImage: selected)), count: 2), isActive: true, environment: environment)
        bridge.view.layoutIfNeeded()

        #expect(tabs.selectedTab === tabs.tabs[0])
        for tab in tabs.tabs {
            #expect(tab.image === normal)
            let image = try #require(tab.selectedImage)
            #expect(image.size == normal.size)
            #expect(image.scale == 3)
            #expect(image.renderingMode == .alwaysTemplate)
            #expect(try centerAlpha(image) > 0)
        }
        #expect(try centerAlpha(normal) == 0)
    }

    @Test func layoutKeepsInstalledImagesAndSwiftUIUpdatesRefreshThem() throws {
        guard #available(iOS 26.1, *) else { return }
        let (tabs, bridge, normal, selected) = fixture()
        let pairs = Array(repeating: NativeTabImages.Pair(icon: Image(uiImage: normal), selectedIcon: Image(uiImage: selected)), count: 2)
        var environment = EnvironmentValues()
        environment.displayScale = 2
        bridge.update(pairs: pairs, isActive: true, environment: environment)
        bridge.view.layoutIfNeeded()
        let firstImage = try #require(tabs.tabs[1].selectedImage)

        tabs.selectedTab = tabs.tabs[1]
        bridge.view.setNeedsLayout()
        bridge.view.layoutIfNeeded()
        #expect(tabs.tabs[1].selectedImage === firstImage)

        environment.displayScale = 3
        tabs.tabs[1].image = UIGraphicsImageRenderer(size: CGSize(width: 32, height: 32)).image { _ in }
        bridge.update(pairs: pairs, isActive: true, environment: environment)
        #expect(tabs.tabs[1].selectedImage === firstImage)
        bridge.view.layoutIfNeeded()
        #expect(tabs.tabs[1].selectedImage !== firstImage)
        #expect(tabs.tabs[1].selectedImage?.scale == 3)
        #expect(tabs.tabs[1].selectedImage?.size == CGSize(width: 32, height: 32))
    }

    @Test func defaultIconsLeaveNativeSymbolVariantsAvailableAndClearOverrides() {
        guard #available(iOS 26.1, *) else { return }
        let (tabs, bridge, normal, selected) = fixture()
        let icon = Image(uiImage: normal)
        let fallback = Array(repeating: NativeTabImages.Pair(icon: icon, selectedIcon: icon), count: 2)
        bridge.update(pairs: fallback, isActive: true, environment: EnvironmentValues())
        bridge.view.layoutIfNeeded()
        #expect(tabs.tabs.allSatisfy { $0.selectedImage == nil })

        bridge.update(pairs: Array(repeating: .init(icon: icon, selectedIcon: Image(uiImage: selected)), count: 2), isActive: true, environment: EnvironmentValues())
        bridge.view.layoutIfNeeded()
        #expect(tabs.tabs.allSatisfy { $0.selectedImage != nil })

        bridge.update(pairs: fallback, isActive: true, environment: EnvironmentValues())
        bridge.view.layoutIfNeeded()
        #expect(tabs.tabs.allSatisfy { $0.selectedImage == nil })
    }

    @Test func inactiveRootDoesNotReplaceTheActiveRootsImages() {
        guard #available(iOS 26.1, *) else { return }
        let (tabs, bridge, normal, selected) = fixture()
        tabs.tabs[0].selectedImage = selected
        let icon = Image(uiImage: normal)
        bridge.update(pairs: Array(repeating: .init(icon: icon, selectedIcon: Image(uiImage: selected)), count: 2), isActive: true, environment: EnvironmentValues())
        bridge.update(pairs: Array(repeating: .init(icon: icon, selectedIcon: icon), count: 2), isActive: false, environment: EnvironmentValues())
        bridge.view.layoutIfNeeded()
        #expect(tabs.tabs[0].selectedImage === selected)
    }

    @available(iOS 26.1, *)
    private func fixture() -> (UITabBarController, NativeTabImages.Controller, UIImage, UIImage) {
        let normal = artwork(filled: false)
        let selected = artwork(filled: true)
        let tabs = UITabBarController()
        tabs.tabs = ["home", "library"].map { id in
            UITab(title: id, image: normal, identifier: id) { _ in UIViewController() }
        }
        tabs.selectedTab = tabs.tabs[0]
        let bridge = NativeTabImages.Controller()
        tabs.addChild(bridge)
        bridge.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return (tabs, bridge, normal, selected)
    }

    private func artwork(filled: Bool) -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 26, height: 26)).image { _ in
            let path = UIBezierPath(roundedRect: CGRect(x: 3, y: 3, width: 20, height: 20), cornerRadius: 5)
            UIColor.black.set()
            if filled { path.fill() } else {
                path.lineWidth = 2
                path.stroke()
            }
        }.withRenderingMode(.alwaysTemplate)
    }

    private func centerAlpha(_ image: UIImage) throws -> UInt8 {
        let cgImage = try #require(image.cgImage)
        var pixel = [UInt8](repeating: 0, count: 4)
        return try pixel.withUnsafeMutableBytes { buffer in
            let context = try #require(CGContext(
                data: buffer.baseAddress,
                width: 1,
                height: 1,
                bitsPerComponent: 8,
                bytesPerRow: 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ))
            context.draw(cgImage, in: CGRect(
                x: 0.5 - CGFloat(cgImage.width) / 2,
                y: 0.5 - CGFloat(cgImage.height) / 2,
                width: CGFloat(cgImage.width),
                height: CGFloat(cgImage.height)
            ))
            return buffer[3]
        }
    }
}
#endif
