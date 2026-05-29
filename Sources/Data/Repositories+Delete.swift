//
//  Repositories+Delete.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-27.
//

import Foundation
import SwiftData


extension Repositories {
    
    /// Delete all entries.
    func deleteEverything() throws {
        try self.performances.deleteEverything()
        try self.venues.deleteEverything()
        try self.bands.deleteEverything()
    }
    
    
    /// Delete a performance and also deletes the associated band and/or venue when these are not referenced by
    /// other performances any more.
    func delete(_ performance: Performance) throws {
        let band = performance.band
        let venue = performance.venue
        
        try self.performances.delete(performance)
        
        if let band, try self.bands.isOrphaned(band) {
            try self.bands.delete(band)
        }
        if let venue, try self.venues.isOrphaned(venue) {
            try self.venues.delete(venue)
        }
    }
    
}
