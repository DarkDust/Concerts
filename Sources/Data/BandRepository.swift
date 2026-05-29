//
//  BandRepository.swift
//  UnitTests
//
//  Created by Marc Haisenko on 2026-05-26.
//

import Foundation
import SwiftData

/// Gathers operations involving bands.
@MainActor
final class BandRepository {
    
    /// Model context backing the operations.
    private
    let context: ModelContext
    
    
    /// Designated initializer.
    init(context: ModelContext) {
        self.context = context
    }
    
    
    /// Create a new band.
    func create(name: String) throws(RepositoryError) -> Band {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let orderedSame = ComparisonResult.orderedSame
        let descriptor = FetchDescriptor<Band>(
            predicate: #Predicate {
                normalizedName.caseInsensitiveCompare($0.name) == orderedSame
            }
        )

        do {
            let existing = try context.fetch(descriptor)
            if let band = existing.first {
                assert(existing.count == 1)
                return band
            }

            let band = Band(name: normalizedName)
            context.insert(band)
            try context.save()
            return band
            
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.unknown(error)
        }
    }
    
    /// Query all bands.
    func fetchAll() throws -> [Band] {
        try context.fetch(FetchDescriptor<Band>())
    }
    
    
    /// Search a band by partial name, case insensitive.
    func search(query: String) throws -> [Band] {
        let descriptor = FetchDescriptor<Band>(
            predicate: #Predicate {
                $0.name.localizedStandardContains(query)
            }
        )
        
        return try context.fetch(descriptor)
    }
    
    
    /// Deletes all entries.
    func deleteEverything() throws {
        try context.delete(model: Band.self)
        try context.save()
    }
    
    
    /// Delete a band.
    ///
    /// - warning: Check whether it's orphaned first via ``isOrphaned(_:)``.
    func delete(_ band: Band) throws {
        context.delete(band)
        try context.save()
    }
    
    
    /// Checks whether any ``Performance`` still references the given band.
    /// This is supposed to be more robust than relying on ``Band/performances`` because it does not rely on the
    /// in-memory relationships.
    func isOrphaned(_ band: Band) throws -> Bool {
        let id = band.id
        let descriptor = FetchDescriptor<Performance>(
            predicate: #Predicate {
                $0.band?.id == id
            }
        )
        return try context.fetchCount(descriptor) == 0
    }
    
}
