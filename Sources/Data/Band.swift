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
    var name: String = ""
    // Note: this should be `@Attribute(.unique)` but that doesn't work, not with the in-memory
    // store and not with iCloud. Same with `#Unique` macro.
    // The uniqueness must therefor be enforced manually in ``BandRepository``, unfortunately.
    
    /// Concert visits.
    @Relationship(inverse: \Performance.band)
    var performances: [Performance]?
    
    
    /// Default initializer.
    init(name: String) {
        self.name = name
    }
    
}
