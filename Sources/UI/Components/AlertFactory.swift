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
        /// Importing a CSV failed with an error.
        case importFailedWithError(any Error)
        /// Importing a CSV failed with a message.
        case importFailedWithMessage(message: String)
        /// Importing a CSV completed successfully.
        case importCompleted(message: String)
        /// Confirm deletion of all data.
        case confirmDeleteAllData(commit: @MainActor () -> Void)
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
        case .importFailedWithError, .importFailedWithMessage:
            return String(
                localized: "Import Failed",
                comment: "Title of an alert that shows when an import operation fails."
            )
            
        case .importCompleted:
            return String(
                localized: "Import Complete",
                comment: "Title for an alert that appears when a CSV import is complete."
            )
            
        case .confirmDeleteAllData:
            return String(
                localized: "Delete All Data?",
                comment: "Confirmation alert title that asks the user if they want to delete all their data."
            )
        }
    }
    
    
    var message: String {
        switch self {
        case .importFailedWithError(let error):
            return error.localizedDescription
            
        case .importFailedWithMessage(let message), .importCompleted(let message):
            return message
            
        case .confirmDeleteAllData:
            return String(
                localized: "This action cannot be undone.",
                comment: "Message shown in an alert when the user attempts to delete all app data."
            )
        }
    }
    
    
    @ViewBuilder
    func actions() -> some View {
        switch self {
        case .importFailedWithError, .importFailedWithMessage, .importCompleted:
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
