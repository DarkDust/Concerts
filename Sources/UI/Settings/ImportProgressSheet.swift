//
//  ImportProgressSheet.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-27.
//


import SwiftUI

/// A simple sheet showing a progress bar while the import is running.
struct ImportProgressSheet: View {

    /// Progress instance to observe.
    let progress: Progress

    var body: some View {
        ProgressView(progress)
            .progressViewStyle(.linear)
            .padding(20)
            .frame(width: 320)
            .interactiveDismissDisabled()
    }
    
}
