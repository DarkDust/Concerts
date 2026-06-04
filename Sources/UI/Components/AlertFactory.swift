//
//  AlertFactory.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-29.
//

import Foundation
import SwiftUI


/// Helper struct to bundle all alert logic.
///
/// In your view, add an alert state:
///
/// ```swift
/// @State private var alert: AlertFactory.Kind?
/// ```
///
/// On your view, use the provided modifier:
///
/// ```swift
/// someView.alert(kind: $alert)
/// ```
///
/// Assign to the `alert` property to show the alert.
struct AlertFactory {
    
    /// Which kind of alert to show.
    enum Kind {
        /// Adding a performance failed.
        case addPerformanceFailed(any Error)
        
        /// Editing an existing performance failed.
        case editPerformanceFailed(any Error)
        
        /// Confirm deletion of all data.
        case confirmDeleteAllData(commit: @MainActor () -> Void)
        
        /// Deleting all data failed.
        case deleteAllDataFailed(any Error)
        
        /// Deleting a performance failed.
        case deletePerformanceFailed(any Error)
        
        /// Importing a CSV completed successfully.
        case importCompleted(message: String)
        
        /// Importing a CSV failed with an error.
        case importFailedWithError(any Error)
        
        /// Importing a CSV failed with a message.
        case importFailedWithMessage(message: String)
        
        /// Exporting as CSV failed with an error.
        case exportFailedWithError(any Error)
        
        /// Exporting as CSV failed with message.
        case exportFailedWithMessage(message: String)
    }
    
}

extension View {
    
    /// Present an alert of a given kind.
    func alert(kind: Binding<AlertFactory.Kind?>) -> some View {
        modifier(AlertFactory.AlertModifier(kind: kind))
    }
    
}


private
extension AlertFactory.Kind {
    
    var title: String {
        switch self {
        case .addPerformanceFailed:
            return String(
                localized: "Failed to add performance",
                comment: "Alert title shown when an attempt to add a performance fails."
            )
            
        case .editPerformanceFailed:
            return String(
                localized: "Failed to edit performance",
                comment: "Alert title shown when an attempt to edit an existing performance fails."
            )
            
        case .confirmDeleteAllData:
            return String(
                localized: "Delete all data?",
                comment: "Confirmation alert title asking the user to confirm deletion of all app data."
            )
            
        case .deleteAllDataFailed:
            return String(
                localized: "Deleting all data failed",
                comment: "Alert title shown when an attempt to delete all app data fails."
            )
            
        case .deletePerformanceFailed:
            return String(
                localized: "Deleting performance failed",
                comment: "Alert title shown when deleting a specific performance fails."
            )
            
        case .exportFailedWithError, .exportFailedWithMessage:
            return String(
                localized: "Export failed",
                comment: "Alert title shown when an import operation fails."
            )
            
        case .importCompleted:
            return String(
                localized: "Import complete",
                comment: "Alert title shown when a CSV import completes successfully."
            )
            
        case .importFailedWithError, .importFailedWithMessage:
            return String(
                localized: "Import failed",
                comment: "Alert title shown when an import operation fails."
            )
        }
    }
    
    
    var message: String {
        switch self {
        case .confirmDeleteAllData:
            return String(
                localized: "This action cannot be undone.",
                comment: "Alert message explaining that deletion cannot be undone."
            )
            
        case .addPerformanceFailed(let error), .editPerformanceFailed(let error),
                .deleteAllDataFailed(let error), .deletePerformanceFailed(let error),
                .exportFailedWithError(let error), .importFailedWithError(let error):
            return error.localizedDescription
            
        case .exportFailedWithMessage(let message), .importCompleted(let message),
                .importFailedWithMessage(let message):
            return message
            
        }
    }
    
    
    @ViewBuilder
    func actions() -> some View {
        switch self {
        case .addPerformanceFailed, .editPerformanceFailed, .deleteAllDataFailed, .deletePerformanceFailed,
                .exportFailedWithError, .exportFailedWithMessage,
                .importCompleted, .importFailedWithError, .importFailedWithMessage:
            Button("OK") { }
            
        case .confirmDeleteAllData(let commit):
            Button("Delete", role: .destructive, action: commit)
            Button("Cancel", role: .cancel) { }
        }
    }
    
}


fileprivate
extension AlertFactory {
    
    /// View modifier to present the alert.
    struct AlertModifier: ViewModifier {
        
        @Binding var kind: AlertFactory.Kind?
        
        func body(content: Content) -> some View {
            content.alert(
                kind?.title ?? "",
                isPresented: isPresentedBinding,
                presenting: kind,
                actions: actions,
                message: message
            )
        }
        
        @ViewBuilder private
        func actions(_ kind: AlertFactory.Kind?) -> some View {
            if let kind {
                kind.actions()
            } else {
                EmptyView()
            }
        }
        
        @ViewBuilder private
        func message(_ kind: AlertFactory.Kind?) -> some View {
            if let kind {
                Text(kind.message)
            } else {
                EmptyView()
            }
        }
        
        private
        var isPresentedBinding: Binding<Bool> {
            Binding(
                get: { kind != nil },
                set: {
                    if !$0 {
                        kind = nil
                    }
                }
            )
        }
    }
    
}
