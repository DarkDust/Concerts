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

}
