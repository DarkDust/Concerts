//
//  AppUIState.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-27.
//

import Foundation
import SwiftUI


/// Shared UI state that needs to be accessed in various places throughout the app.
@Observable final
class AppUIState {
    
    /// Sheets used throughout the app.
    enum Sheet: Identifiable {
        /// The ``AddPerformanceView`` sheet.
        case addPerformance
        
        var id: Self { self }
    }
    
    /// Currently visible sheet.
    var presentedSheet: Sheet?
    
    /// Whether the search bar should be focused.
    var requestSearchFocus: Bool = false
    
}
