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
#if os(macOS)
                .frame(minWidth: 640, minHeight: 480)
#endif
        }
        .modelContainer(SharedModelContainer.instance)
        .environment(Repositories(context: SharedModelContainer.instance.mainContext))
        .environment(uiState)
#if os(macOS)
        .defaultSize(width: 800, height: 600)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button {
                    uiState.presentedSheet = .addPerformance
                } label: {
                    Label(
                        LocalizedStringResource("Add Performance", comment: "Menu entry to add a new performance)"),
                        systemImage: "plus"
                    )
                }
                .keyboardShortcut("n")
            }
            
            CommandGroup(after: .pasteboard) {
                Divider()
                
                Button {
                    uiState.requestSearchFocus = true
                } label: {
                    Label(
                        LocalizedStringResource("Find", comment: "A menu item that searches for a performance."),
                        systemImage: "magnifyingglass"
                    )
                }
                .keyboardShortcut("f", modifiers: .command)
            }
        }
#endif
        
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
