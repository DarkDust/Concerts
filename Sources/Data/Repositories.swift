//
//  Repositories.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-27.
//

import Foundation
import SwiftData


/// Gathers all classes providing database operations for convenient SwiftUI data management.
@MainActor @Observable
final class Repositories {
    
    /// Repository for bands.
    let bands: BandRepository
    
    /// Repository for venues.
    let venues: VenueRepository
    
    /// Repository for performances.
    let performances: PerformanceRepository
    
    
    /// Designated initializer.
    init(context: ModelContext) {
        self.bands = BandRepository(context: context)
        self.venues = VenueRepository(context: context)
        self.performances = PerformanceRepository(context: context)
    }
    
}


extension Repositories {
    
    /// Scenario to simulate for mocking.
    enum MockScenario {
        /// A fresh, empty database.
        case empty
        
        /// Database with a few entries.
        case basic
    }
    
    
    /// Create and optionally prefill repositories for mocking.
    @discardableResult @MainActor
    static func mock(scenario: MockScenario, container: ModelContainer) -> Repositories {
        let context = container.mainContext
        let repositories = Repositories(context: context)
        
        switch scenario {
        case .empty:
            break
            
        case .basic:
            let date2 = DateComponents(calendar: .current, year: 2026, month: 2, day: 14).date!
            let band4 = try! repositories.bands.create(name: "EMMON")
            let band5 = try! repositories.bands.create(name: "Klangstabil")
            let venue2 = try! repositories.venues.create(name: "Feierwerk")
            _ = try! repositories.performances.add(band: band4, venue: venue2, date: date2, partialAttendance: false)
            _ = try! repositories.performances.add(band: band5, venue: venue2, date: date2, partialAttendance: false)
            
            let date1 = DateComponents(calendar: .current, year: 2025, month: 12, day: 1).date!
            let band1 = try! repositories.bands.create(name: "GOST")
            let band2 = try! repositories.bands.create(name: "Kælan Mikla")
            let band3 = try! repositories.bands.create(name: "Pertubator")
            let venue1 = try! repositories.venues.create(name: "Technikum")
            _ = try! repositories.performances.add(band: band1, venue: venue1, date: date1, partialAttendance: false)
            _ = try! repositories.performances.add(band: band2, venue: venue1, date: date1, partialAttendance: false)
            _ = try! repositories.performances.add(band: band3, venue: venue1, date: date1, partialAttendance: false)
            
            let date3 = DateComponents(calendar: .current, year: 2023, month: 5, day: 23).date!
            let band6 = try! repositories.bands.create(name: "Gggoldd")
            let band7 = try! repositories.bands.create(name: "MONO")
            _ = try! repositories.performances.add(band: band6, venue: venue2, date: date3, partialAttendance: true)
            _ = try! repositories.performances.add(band: band7, venue: venue2, date: date3, partialAttendance: false)
        }
        
        return repositories
    }
    
}
