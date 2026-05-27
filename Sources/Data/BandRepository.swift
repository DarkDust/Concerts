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
    
}
