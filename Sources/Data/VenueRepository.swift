//
//  VenueRepository.swift
//  UnitTests
//
//  Created by Marc Haisenko on 2026-05-27.
//

import Foundation
import SwiftData

@MainActor
final class VenueRepository {
    
    /// Model context backing the operations.
    private
    let context: ModelContext
    
    
    /// Designated initializer.
    init(context: ModelContext) {
        self.context = context
    }
    
    
    /// Create a new venue.
    func create(name: String, city: String? = nil) throws(RepositoryError) -> Venue {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let orderedSame = ComparisonResult.orderedSame
        let descriptor = FetchDescriptor<Venue>(
            predicate: #Predicate {
                normalizedName.caseInsensitiveCompare($0.name) == orderedSame
            }
        )

        do {
            let existing = try context.fetch(descriptor)
            if let venue = existing.first {
                assert(existing.count == 1)
                return venue
            }

            let venue = Venue(name: normalizedName)
            context.insert(venue)
            try context.save()
            return venue
            
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.unknown(error)
        }
    }
    
    
    /// Query all venues.
    func fetchAll() throws -> [Venue] {
        try context.fetch(FetchDescriptor<Venue>())
    }
    
    
    /// Search a venue by partial name, case insensitive.
    func search(query: String) throws -> [Venue] {
        let descriptor = FetchDescriptor<Venue>(
            predicate: #Predicate {
                $0.name.localizedStandardContains(query)
            }
        )
        
        return try context.fetch(descriptor)
    }
    
    
    /// Deletes all entries.
    func deleteEverything() throws {
        try context.delete(model: Venue.self)
        try context.save()
    }
    
    
    /// Delete a venue.
    ///
    /// - warning: Check whether it's orphaned first via ``isOrphaned(_:)``.
    func delete(_ venue: Venue) throws {
        context.delete(venue)
        try context.save()
    }
    
    
    /// Checks whether any ``Performance`` still references the given band.
    /// This is supposed to be more robust than relying on ``Venue/performances`` because it does not rely on the
    /// in-memory relationships.
    func isOrphaned(_ venue: Venue) throws -> Bool {
        let id = venue.id
        let descriptor = FetchDescriptor<Performance>(
            predicate: #Predicate {
                $0.venue?.id == id
            }
        )
        
        return try context.fetchCount(descriptor) == 0
    }
    
}
