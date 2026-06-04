//
//  MaxWidthPreference.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-06-04.
//

import Foundation
import SwiftUI


/// A preference for measuring the maximum width of view, for example to have all views of a "column" in a `List` to
/// use the same width.
struct MaxWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

extension View {
    
    /// Convenience: report the receivers maximum width using ``MaxWidthPreferenceKey``.
    /// Assumes the receiver is a `Text`.
    func reportMaxWidth() -> some View {
        fixedSize()
            .background {
                GeometryReader {
                    (proxy) in
                    
                    Color.clear.preference(
                        key: MaxWidthPreferenceKey.self,
                        value: proxy.size.width
                    )
                }
            }
    }
    
}
