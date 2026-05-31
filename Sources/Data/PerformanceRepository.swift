//
//  PerformanceRepository.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-27.
//

import Foundation
import SwiftData

@MainActor
final class PerformanceRepository {
    
    /// Model context backing the operations.
    private
    let context: ModelContext
    
    
    /// Designated initializer.
    init(context: ModelContext) {
        self.context = context
    }
    
    
    /// Add a performance.
    @discardableResult
    func add(band: Band, venue: Venue, date: Date, partialAttendance: Bool) throws -> Performance {
        let normalizedDate = Performance.normalizedConcertDate(date)
        let nextSequence = try Performance.nextSequence(for: normalizedDate, in: context)
        
        let performance = Performance(
            date: normalizedDate,
            sequence: nextSequence,
            partialAttendance: partialAttendance,
            band: band,
            venue: venue
        )
        
        context.insert(performance)
        try context.save()
        return performance
    }
    
    /// Edit an existing performance
    ///
    /// - note: Don't call this directly. Use ``Repositories/edit(performance:band:venue:)`` instead.
    @discardableResult
    func edit(performance: Performance, band: Band, venue: Venue, partialAttendence: Bool) throws -> Performance {
        performance.band = band
        performance.venue = venue
        performance.partialAttendance = partialAttendence
        try context.save()
        return performance
    }
    
    
    /// Query all performances.
    func fetchAll() throws -> [Performance] {
        try context.fetch(FetchDescriptor<Performance>())
    }
    
    
    /// Deletes all entries.
    func deleteEverything() throws {
        try context.delete(model: Performance.self)
        try context.save()
    }
    
    
    /// Delete a performance.
    ///
    /// - note: Don't call this directly. Use ``Repositories/delete(_:)`` instead.
    func delete(_ performance: Performance) throws {
        context.delete(performance)
        try context.save()
    }
    
}
