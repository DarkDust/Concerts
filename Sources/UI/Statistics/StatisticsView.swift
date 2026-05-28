//
//  StatisticsView.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-27.
//

import Foundation
import SwiftUI
import SwiftData
import Charts


struct StatisticsView: View {
    
    @Query private
    var performances: [Performance]
    
    @Environment(\.colorScheme) private
    var colorScheme
    
    
    var body: some View {
        let statistics = Statistics.derive(from: performances, colorScheme: colorScheme)
        
        VStack {
            Grid(alignment: .leading) {
                GridRow {
                    Text("Bands:")
                    Text(String(statistics.numberOfBands))
                }
                GridRow {
                    Text("Venues:")
                    Text(String(statistics.numberOfVenues))
                }
                GridRow {
                    Text("Performances:")
                    Text(String(statistics.numberOfPerformances))
                }
            }
            
            Chart {
                ForEach(statistics.numberOfPerformancesPerYear, id: \.year) {
                    (yearData) in
                    
                    BarMark(
                        x: .value("Year", String(yearData.year)),
                        y: .value("Count", yearData.count)
                    )
                    .foregroundStyle(yearData.color)
                    .annotation(position: .top) {
                        Text(String(yearData.count))
                            .font(.caption)
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
        .padding()
    }
    
}


private
extension StatisticsView {
    
    struct Statistics {
        let numberOfBands: Int
        let numberOfVenues: Int
        let numberOfPerformances: Int
        
        let numberOfPerformancesPerYear: [(year: Int, count: Int, color: Color)]
    }
    
}


private
extension StatisticsView.Statistics {
    
    static var empty: Self {
        return Self(
            numberOfBands: 0,
            numberOfVenues: 0,
            numberOfPerformances: 0,
            numberOfPerformancesPerYear: []
        )
    }
    
    static func derive(from performances: [Performance], colorScheme: ColorScheme) -> Self {
        var bands: Set<String> = []
        var venues: Set<String> = []
        var numberOfPerformances = 0
        
        var numberOfPerformancesPerYear: [Int: Int] = [:]
        
        for performance in performances where !performance.partialAttendance {
            if let bandName = performance.band?.name {
                bands.insert(bandName)
            }
            if let venueName = performance.venue?.name {
                venues.insert(venueName)
            }
            numberOfPerformances += 1
            
            let year = Calendar.current.component(.year, from: performance.date)
            numberOfPerformancesPerYear[year, default: 0] += 1
        }
        
        let colors = DiscreteColorGradient.colors(
            from: .green,
            to: .blue,
            steps: numberOfPerformancesPerYear.count,
            colorScheme: colorScheme
        )
        
        var performancesPerYear: [(year: Int, count: Int, color: Color)] = []
        for (index, year) in numberOfPerformancesPerYear.keys.sorted().enumerated() {
            let count = numberOfPerformancesPerYear[year]!
            performancesPerYear.append((year: year, count: count, color: colors[index]))
        }
        
        return Self(
            numberOfBands: bands.count,
            numberOfVenues: venues.count,
            numberOfPerformances: performances.count,
            numberOfPerformancesPerYear: performancesPerYear
        )
    }
    
}
