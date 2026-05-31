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
        /// The ``AddOrEditPerformanceView`` sheet, to add a new performance.
        case addPerformance
        
        /// The ``AddOrEditPerformanceView`` sheet, to edit an existing.
        case editPerformance(Performance)
        
        var id: String {
            switch self {
            case .addPerformance:
                return "addPerformance"
            case .editPerformance(let performance):
                return "editPerformance-\(performance.id)"
            }
        }
    }
    
    
    /// Currently visible sheet.
    var presentedSheet: Sheet?
    
    /// Whether the search bar should be focused.
    var requestSearchFocus: Bool = false
    
}
