//
//  Venue.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-26.
//

import SwiftData


/// Venue or event (festival).
@Model
final class Venue {
    
    /// Name of the venue.
    var name: String
    // Note: this should be `@Attribute(.unique)` but that doesn't work, at least not with the
    // in-memory store: it does not prevent insertion of a duplicate! Same with `#Unique` macro.
    // The uniqueness must therefor be enforced manually in ``VenueRepository``, unfortunately.
    
    /// City in which the venue is located if outside my default city.
    var city: String?
    
    /// Which concert were visited at the venue.
    @Relationship(inverse: \Performance.venue)
    var performances: [Performance] = []
    
    
    /// Default initializer.
    init(name: String, city: String? = nil) {
        self.name = name
        self.city = city
    }
    
}
