//
//  DataTests.swift
//  UnitTests
//
//  Created by Marc Haisenko on 2026-05-26.
//

import Foundation
import SwiftData
import Testing

struct DataTests {
    
    @Test
    func testAddVisits() throws {
        let container = ModelContainer.mock()
        let context = ModelContext(container)
        
        // Create and insert band
        let band1 = Band(name: "In Strict Confidence")
        let band2 = Band(name: "Suicide Commando")
        context.insert(band1)
        context.insert(band2)
        try context.save()

        // Fetch bands back
        let bands = try context.fetch(FetchDescriptor<Band>())
        #expect(bands.count == 2)
        var haveBand1 = false
        var haveBand2 = false
        for band in bands {
            if band.name == "In Strict Confidence" {
                haveBand1 = true
            }
            if band.name == "Suicide Commando" {
                haveBand2 = true
            }
        }
        #expect(haveBand1)
        #expect(haveBand2)
        
        // Create venue
        let venue = Venue(name: "Backstage Werk")
        context.insert(venue)
        try context.save()
        
        // Fetch venue back
        let venues = try context.fetch(FetchDescriptor<Venue>())
        #expect(venues.count == 1)
        #expect(venues.first?.name == "Backstage Werk")
        
        // Create visits, one after another
        let date = Performance.normalizedConcertDate(.now)
        let sequence1 = try Performance.nextSequence(for: date, in: context)
        #expect(sequence1 == 1)
        let visit1 = Performance(date: date, sequence: sequence1, band: band1, venue: venue)
        context.insert(visit1)
        try context.save()
        
        let sequence2 = try Performance.nextSequence(for: date, in: context)
        #expect(sequence2 == 2)
        let visit2 = Performance(date: date, sequence: sequence2, band: band2, venue: venue)
        context.insert(visit2)
        try context.save()
        
        // Fetch visits back
        let visits = try context.fetch(FetchDescriptor<Performance>())
        #expect(visits.count == 2)
        var haveVisit1 = false
        var haveVisit2 = false
        for visit in visits {
            switch visit.band.name {
            case band1.name:
                haveVisit1 = true
                
            case band2.name:
                haveVisit2 = true
                
            default:
                assertionFailure("Unexpected band name: \(visit.band.name)")
            }
        }
        #expect(haveVisit1)
        #expect(haveVisit2)
    }
    
}
