//
//  ModelContainer.swift
//  UITests
//
//  Created by Marc Haisenko on 2026-05-26.
//

import Foundation
import SwiftData

extension ModelContainer {
    
    /// Create model for the app, taking UI testing into account.
    static func create() -> ModelContainer {
        let isTesting = ProcessInfo.processInfo.environment["UITesting"] != nil
        let modelConfiguration = ModelConfiguration(schema: Self.concertsSchema, isStoredInMemoryOnly: isTesting)
        
        do {
            return try ModelContainer(for: Self.concertsSchema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    
    /// Create model for SwiftUI previews.
    static func mock() -> ModelContainer {
        let modelConfiguration = ModelConfiguration(schema: Self.concertsSchema, isStoredInMemoryOnly: true)
        
        do {
            return try ModelContainer(for: Self.concertsSchema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
}


private
extension ModelContainer {
    
    static let concertsSchema = Schema([
        Band.self,
        Venue.self,
        ConcertVisit.self,
    ])
    
}
