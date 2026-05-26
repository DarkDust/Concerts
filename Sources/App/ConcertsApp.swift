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
    
    /// The main SwiftData model container.
    var sharedModelContainer = ModelContainer.create()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
