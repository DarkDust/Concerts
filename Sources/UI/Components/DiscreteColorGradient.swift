//
//  DiscreteColorGradient.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-28.
//

import Foundation
import SwiftUI

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif


struct DiscreteColorGradient {
    
    /// Interpolate between two colors and derive a given number of colors on that gradient.
    ///
    /// - parameter startColor Color at the start of the gradient.
    /// - parameter endColor Color at the end of the gradient.
    /// - parameter steps Number of colors to derive.
    /// - parameter colorScheme Current color scheme to take into account when resolving colors.
    static func colors(from startColor: Color, to endColor: Color, steps: Int, colorScheme: ColorScheme) -> [Color] {
        // It's inconvenient to work with long identifier names here…
        // swiftlint:disable identifier_name
        
        let startColor = startColor.resolved(in: colorScheme)
        let endColor = endColor.resolved(in: colorScheme)
        
        var sR: CGFloat = 0
        var sG: CGFloat = 0
        var sB: CGFloat = 0
        var sA: CGFloat = 0
        var eR: CGFloat = 0
        var eG: CGFloat = 0
        var eB: CGFloat = 0
        var eA: CGFloat = 0
        
        #if canImport(AppKit)
            startColor.usingColorSpace(.deviceRGB)?
                .getRed(&sR, green: &sG, blue: &sB, alpha: &sA)
            endColor.usingColorSpace(.deviceRGB)?
                .getRed(&eR, green: &eG, blue: &eB, alpha: &eA)
        #else
            startColor.getRed(&sR, green: &sG, blue: &sB, alpha: &sA)
            endColor.getRed(&eR, green: &eG, blue: &eB, alpha: &eA)
        #endif
        
        return (0..<steps).map { index in
            let t = CGFloat(index) / CGFloat(max(steps - 1, 1))
            let r = sR + (eR - sR) * t
            let g = sG + (eG - sG) * t
            let b = sB + (eB - sB) * t
            let a = sA + (eA - sA) * t
            
            return Color(
                .sRGB,
                red: Double(r),
                green: Double(g),
                blue: Double(b),
                opacity: Double(a)
            )
        }
        // swiftlint:enable identifier_name
    }
    
}

#if canImport(AppKit)
private
extension Color {
    
    /// Convert receiver to a `NSColor` using the given color scheme.
    func resolved(in colorScheme: ColorScheme) -> NSColor {
        let appearance: NSAppearance = colorScheme == .dark
            ? NSAppearance(named: .darkAqua)!
            : NSAppearance(named: .aqua)!
        
        var result: NSColor = .clear
        appearance.performAsCurrentDrawingAppearance {
            result = NSColor(self)
        }
        
        return result
    }
    
}
#elseif canImport(UIKit)
private
extension Color {
    
    /// Convert receiver to a `UIColor` using the given color scheme.
    func resolved(in colorScheme: ColorScheme) -> UIColor {
        let traits = UITraitCollection(
            userInterfaceStyle: colorScheme == .dark ? .dark : .light
        )
        return UIColor(self).resolvedColor(with: traits)
    }
    
}
#endif
