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
    
    @Test @MainActor
    func testAddVisitsRaw() throws {
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
            switch visit.band?.name {
            case band1.name:
                haveVisit1 = true
                
            case band2.name:
                haveVisit2 = true
                
            default:
                assertionFailure("Unexpected band name: \(visit.band?.name ?? "?")")
            }
        }
        #expect(haveVisit1)
        #expect(haveVisit2)
    }
    
    
    @Test @MainActor
    func testAddVisitsRepositories() throws {
        let container = ModelContainer.mock()
        let context = ModelContext(container)
        let repositories = Repositories(context: context)
        
        // Create and insert band
        let band1 = try repositories.bands.create(name: "In Strict Confidence")
        let band2 = try repositories.bands.create(name: "Suicide Commando")
        #expect(band1.id != band2.id)

        // Fetch bands back
        let bands = try repositories.bands.fetchAll()
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
        let venue = try repositories.venues.create(name: "Backstage Werk")
        
        // Fetch venue back
        let venues = try repositories.venues.fetchAll()
        #expect(venues.count == 1)
        #expect(venues.first?.name == "Backstage Werk")
        
        // Create visits, one after another
        let date = Date.now
        let visit1 = try repositories.performances.add(band: band1, venue: venue, date: date, partialAttendance: false)
        #expect(visit1.sequence == 1)
        
        let visit2 = try repositories.performances.add(band: band2, venue: venue, date: date, partialAttendance: false)
        #expect(visit2.sequence == 2)

        // Fetch visits back
        let visits = try repositories.performances.fetchAll()
        #expect(visits.count == 2)
        var haveVisit1 = false
        var haveVisit2 = false
        for visit in visits {
            switch visit.band?.name {
            case band1.name:
                haveVisit1 = true
                
            case band2.name:
                haveVisit2 = true
                
            default:
                assertionFailure("Unexpected band name: \(visit.band?.name ?? "?")")
            }
        }
        #expect(haveVisit1)
        #expect(haveVisit2)
    }
    
    
    @Test @MainActor
    func testDuplicateNames() throws {
        let container = ModelContainer.mock()
        let context = ModelContext(container)
        let repositories = Repositories(context: context)
        
        let band1 = try repositories.bands.create(name: "Zanias")
        let band2 = try repositories.bands.create(name: "Zanias")
        let band3 = try repositories.bands.create(name: "Linea Aspera")
        #expect(band1.id == band2.id)
        #expect(band3.id != band1.id)
        
        let venue1 = try repositories.venues.create(name: "Milla")
        let venue2 = try repositories.venues.create(name: "Milla")
        let venue3 = try repositories.venues.create(name: "ZIRKA")
        #expect(venue1.id == venue2.id)
        #expect(venue3.id != venue1.id)
    }
    
    
    @Test @MainActor
    func testEditPerformance() throws {
        let container = ModelContainer.mock()
        let context = ModelContext(container)
        let repositories = Repositories(context: context)
        
        // Create and insert performance.
        let band1 = try repositories.bands.create(name: "Aesthetic Perfection")
        let venue1 = try repositories.venues.create(name: "Backstage Club")
        let performance = try repositories.performances.add(band: band1, venue: venue1, date: .now, partialAttendance: false)
        #expect(performance.band?.name == "Aesthetic Perfection")
        #expect(performance.venue?.name == "Backstage Club")
        #expect(!performance.partialAttendance)
        
        // Change it.
        let band2 = try repositories.bands.create(name: "Welle: Erdball")
        let venue2 = try repositories.venues.create(name: "WGT (AGRA)")
        let updatedPerformance = try repositories.edit(performance: performance, band: band2, venue: venue2, partialAttendence: true)
        #expect(updatedPerformance.id == performance.id)
        #expect(performance.band?.name == "Welle: Erdball")
        #expect(performance.venue?.name == "WGT (AGRA)")
        #expect(performance.partialAttendance)
        
        // Check the old band and venue have vanished.
        let bands = try repositories.bands.fetchAll()
        let venues = try repositories.venues.fetchAll()
        #expect(bands.count == 1)
        #expect(bands[0].name == "Welle: Erdball")
        #expect(venues.count == 1)
        #expect(venues[0].name == "WGT (AGRA)")
    }
}
