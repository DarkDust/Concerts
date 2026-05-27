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
    func add(band: Band, venue: Venue, date: Date) throws(RepositoryError) -> Performance {
        do {
            let normalizedDate = Performance.normalizedConcertDate(date)
            let nextSequence = try Performance.nextSequence(for: normalizedDate, in: context)
            
            let performance = Performance(date: normalizedDate, sequence: nextSequence, band: band, venue: venue)
            context.insert(performance)
            try context.save()
            return performance
            
        } catch {
            throw RepositoryError.unknown(error)
        }
    }
    
    
    /// Query all performances.
    func fetchAll() throws -> [Performance] {
        try context.fetch(FetchDescriptor<Performance>())
    }
    
}
