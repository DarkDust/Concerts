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
    
    /// Boolean to toggle the ``AddPerformanceView`` sheet.
    @State
    private var showingAddPerformance = false
    
    
    var body: some Scene {
        WindowGroup {
            MainView(showingAddPerformance: $showingAddPerformance)
        }
        .modelContainer(ModelContainer.create())
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Performance") {
                    showingAddPerformance = true
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
