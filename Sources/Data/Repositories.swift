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
