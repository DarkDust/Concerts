//
//  ConcertVisit.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-26.
//

import Foundation
import SwiftData


/// A single concert visit.
@Model
final class ConcertVisit {
    /// Date of the concert.
    var date: Date
    
    /// Chronological order within the day.
    var sequence: Int
    
    /// Whether the concert was no seen completely (e.g. arrived later or left early).
    var partialAttendance: Bool
    
    /// Optional notes.
    var notes: String?
    
    /// Band playing at the concert.
    var band: Band
    
    /// Venue at which the concert took place.
    var venue: Venue
    
    
    /// Default initializer.
    init(
        date: Date,
        sequence: Int,
        partialAttendance: Bool = false,
        notes: String? = nil,
        band: Band,
        venue: Venue
    ) {
        self.date = date
        self.sequence = sequence
        self.partialAttendance = partialAttendance
        self.notes = notes
        self.band = band
        self.venue = venue
    }
    
    
    /// Normalize a date by stripping its time.
    static func normalizedConcertDate(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
    
    
    /// Find the next sequence for a given day.
    static func nextSequence(for date: Date, in context: ModelContext) throws -> Int {
        let calendar = Calendar.current
        
        // We're normalizing dates so we _could_ do an equality check. But that's unreliable.
        // The #Predicate macro does not support `Calendar.current.isDate(_:inSameDayAs:)`, so the
        // next best thing is to check whether entry's date is within the start and end of the
        // given date.
        let startOfDay = calendar.startOfDay(for: date)
        let nextDay = calendar.date(
            byAdding: .day,
            value: 1,
            to: startOfDay
        )!
        
        let predicate = #Predicate<ConcertVisit> {
            $0.date >= startOfDay &&
            $0.date < nextDay
        }
        
        let descriptor = FetchDescriptor<ConcertVisit>(
            predicate: predicate,
            sortBy: [
                SortDescriptor(\.sequence, order: .reverse)
            ]
        )
        
        let latest = try context.fetch(descriptor).first
        return (latest?.sequence ?? 0) + 1
    }
    
}
