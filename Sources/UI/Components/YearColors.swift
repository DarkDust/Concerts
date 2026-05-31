//
//  YearColors.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-31.
//

import Foundation
import SwiftUI

extension Int {
    
    /// Interprete the receiver as a year and derive a color to better distinguish between dates.
    func yearColor(colorScheme: ColorScheme) -> Color {
        guard let cycle = yearColors[colorScheme] else {
            assertionFailure("Unknown color scheme")
            return .primary
        }
        
        // My concert dates start in 2016, so shift the year accordingly and get a color.
        let index = (self - 2016).modulo(cycle.count)
        return cycle[index]
    }
    
}


extension Date {
    
    /// Derive a color to better distinguish between dates, based on year.
    func yearColor(colorScheme: ColorScheme) -> Color {
        let year = Calendar.current.component(.year, from: self)
        return year.yearColor(colorScheme: colorScheme)
    }
    
}


/// List of colors to pick from.
///
/// The colors are chosen so that two subsequent years are visually distinct while not repeating the cycle too early.
private
let yearColors: [ColorScheme: [Color]] = {
    var result: [ColorScheme: [Color]] = [:]
    
    for scheme in ColorScheme.allCases {
        let colors = DiscreteColorGradient.colors(
            stops: [.yellow, .green, .blue, .purple, .yellow],
            steps: 3,
            colorScheme: scheme
        )
        result[scheme] = colors
    }
    
    return result
}()


#Preview {
    @Previewable @Environment(\.colorScheme)
    var colorScheme
    
    VStack {
        ForEach(2016 ..< 2037) {
            (year) in
            
            Text(String(year)).foregroundStyle(year.yearColor(colorScheme: colorScheme))
        }
        
    }
    .padding()
}
