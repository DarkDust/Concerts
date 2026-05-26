//
//  Band.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-26.
//

import SwiftData

/// A band.
@Model
final class Band {
    /// Name of the band.
    @Attribute(.unique)
    var name: String
    
    /// Concert visits.
    @Relationship(inverse: \ConcertVisit.band)
    var visits: [ConcertVisit] = []
    
    
    /// Default initializer.
    init(name: String) {
        self.name = name
    }
    
}
