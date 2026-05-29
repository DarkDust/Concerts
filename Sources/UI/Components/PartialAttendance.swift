//
//  PartialAttendance.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-29.
//

import Foundation
import SwiftUI

private
struct PartialAttendanceModifier: ViewModifier {
    
    let partialAttendance: Bool
    
    func body(content: Content) -> some View {
        if partialAttendance {
            content
                .foregroundStyle(.secondary)
                .italic()
        } else {
            content
        }
    }
    
}


extension View {
    
    /// Modify the font and foreground style when a performance was only attended partially.
    func partialAttendance(
        _ partialAttendance: Bool
    ) -> some View {
        modifier(
            PartialAttendanceModifier(
                partialAttendance: partialAttendance
            )
        )
    }
    
}
