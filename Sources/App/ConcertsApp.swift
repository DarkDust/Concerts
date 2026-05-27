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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(ModelContainer.create())
    }
    
}
