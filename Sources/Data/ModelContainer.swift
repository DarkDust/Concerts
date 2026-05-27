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
        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
        
        let modelConfiguration: ModelConfiguration
        if isTesting || isPreview {
            modelConfiguration = ModelConfiguration(schema: Self.concertsSchema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        } else {
            modelConfiguration = ModelConfiguration(schema: Self.concertsSchema, cloudKitDatabase: .private("iCloud.net.darkdust.Concerts"))
        }
        
        do {
            return try ModelContainer(for: Self.concertsSchema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    
    /// Create model for SwiftUI previews.
    @MainActor
    static func mock(scenario: Repositories.MockScenario = .empty) -> ModelContainer {
        let modelConfiguration = ModelConfiguration(schema: Self.concertsSchema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        
        do {
            let container = try ModelContainer(for: Self.concertsSchema, configurations: [modelConfiguration])
            Repositories.mock(scenario: scenario, container: container)
            return container
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
        Performance.self,
    ])
    
}
