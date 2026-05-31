//
//  ConditionalViewModifier.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-31.
//

import Foundation
import SwiftUI

extension View {
    
    /// Conditionally applies view modifiers when a condition applies.
    ///
    /// Use it like this:
    ///
    /// ```swift
    /// someView.if(someCondition == someValue) {
    ///     $0.someMoreViewModifiers()
    /// }
    /// ```
    @ViewBuilder
    func conditional<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
}
