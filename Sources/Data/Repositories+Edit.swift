//
//  Repositories+Edit.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-31.
//

import Foundation
import SwiftData

extension Repositories {
    
    /// Change a performance to use the given band and venue.
    @discardableResult
    func edit(performance: Performance, band: Band, venue: Venue, partialAttendence: Bool) throws -> Performance {
        let previousBand = performance.band
        let previousVenue = performance.venue
        
        try self.performances.edit(
            performance: performance,
            band: band,
            venue: venue,
            partialAttendence: partialAttendence
        )
        if let previousBand, previousBand != band, try self.bands.isOrphaned(previousBand) {
            try bands.delete(previousBand)
        }
        if let previousVenue, previousVenue != venue, try self.venues.isOrphaned(previousVenue) {
            try venues.delete(previousVenue)
        }
        
        return performance
    }
    
}
