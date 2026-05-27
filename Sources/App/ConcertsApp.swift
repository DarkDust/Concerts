//
//  ConcertsApp.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-26.
//

import SwiftUI
import SwiftData

@main
struct ConcertsApp: App {
    
    /// Shared UI state used throughout the app.
    @State
    private var uiState = AppUIState()
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(SharedModelContainer.instance)
        .environment(Repositories(context: SharedModelContainer.instance.mainContext))
        .environment(uiState)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button(
                    LocalizedStringResource("Add Performance", comment: "Menu entry to add a new performance)")
                ) {
                    uiState.presentedSheet = .addPerformance
                }
                .keyboardShortcut("n")
            }
        }
        
        #if os(macOS)
        Settings {
            SettingsView()
                .navigationTitle("Settings")
                .modelContainer(SharedModelContainer.instance)
                .environment(Repositories(context: SharedModelContainer.instance.mainContext))
        }
        #endif
    }
    
}


/// Workaround for a global model container without a stored property in ``ConcertsApp``.
/// Avoids race conditions with Swift Previews.
private
enum SharedModelContainer {

    static let instance: ModelContainer = {
        ModelContainer.create()
    }()

}
