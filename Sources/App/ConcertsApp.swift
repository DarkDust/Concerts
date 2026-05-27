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
        .modelContainer(ModelContainer.create())
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
        }
        #endif
    }
    
}
