//
//  ImageBackgroundViewModifier.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-07-13.
//

import SwiftUI

extension Image {
    
    /// Use the receiver to fill a background, preserving aspect ratio.
    func asBackground() -> some View {
        self
            .resizable()
            .scaledToFill()
//            .aspectRatio(1, contentMode: .fill)
            .ignoresSafeArea()
    }
    
}
