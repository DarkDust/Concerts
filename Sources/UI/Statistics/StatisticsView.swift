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
    
    @Environment(\.verticalSizeClass) private
    var verticalSizeClass
    
    
    var body: some View {
        let statistics = Statistics.derive(from: performances, colorScheme: colorScheme)
        
        VStack(alignment: .leading) {
            
            if verticalSizeClass != .compact {
                textStatistics(statistics)
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
        
        let top10Bands: [(band: String, count: Int, rank: Int?)]
    }
    
    
    @ViewBuilder
    func textStatistics(_ statistics: Statistics) -> some View {
        Grid(alignment: .leading) {
            GridRow {
                Text(String()) // To avoid getting a `""` in the Localizable.xcstrings
                Text("Bands:")
                Text(String(statistics.numberOfBands))
            }
            GridRow {
                Text(String()) // To avoid getting a `""` in the Localizable.xcstrings
                Text("Venues:")
                Text(String(statistics.numberOfVenues))
            }
            GridRow {
                Text(String()) // To avoid getting a `""` in the Localizable.xcstrings
                Text("Performances:")
                Text(String(statistics.numberOfPerformances))
            }
            
            Divider()
                .gridCellColumns(4)
            
            GridRow {
                Text("Top 10 bands:")
                    .font(.headline)
                    .padding(.bottom, 4)
                    .gridCellColumns(2)
            }
            
            let top10Bands = statistics.top10Bands
            ForEach(top10Bands.indices, id: \.self) {
                (index) in
                
                GridRow {
                    if let rank = top10Bands[index].rank {
                        Text(String(rank) + ".")
                            .monospacedDigit()
                            .gridColumnAlignment(.trailing)
                    } else {
                        Text(String()) // To avoid getting a `""` in the Localizable.xcstrings
                    }
                    
                    Text(top10Bands[index].band + ":")
                    
                    Text(String(top10Bands[index].count))
                }
            }
        }
    }
    
}


private
extension StatisticsView.Statistics {
    
    static var empty: Self {
        return Self(
            numberOfBands: 0,
            numberOfVenues: 0,
            numberOfPerformances: 0,
            numberOfPerformancesPerYear: [],
            top10Bands: [],
        )
    }
    
    static func derive(from performances: [Performance], colorScheme: ColorScheme) -> Self {
        var bands: Set<String> = []
        var venues: Set<String> = []
        var numberOfPerformances = 0
        var numberOfPerformancesPerYear: [Int: Int] = [:]
        var bandsCount: [String: Int] = [:]
        
        
        for performance in performances where !performance.partialAttendance {
            if let bandName = performance.band?.name {
                bands.insert(bandName)
                
                if !performance.partialAttendance {
                    bandsCount[bandName, default: 0] += 1
                }
            }
            if let venueName = performance.venue?.name {
                venues.insert(venueName)
            }
            numberOfPerformances += 1
            
            let year = Calendar.current.component(.year, from: performance.date)
            numberOfPerformancesPerYear[year, default: 0] += 1
        }
        
        return Self(
            numberOfBands: bands.count,
            numberOfVenues: venues.count,
            numberOfPerformances: performances.count,
            numberOfPerformancesPerYear: derivePerformancesPerYear(
                numberOfPerformancesPerYear,
                colorScheme: colorScheme
            ),
            top10Bands: deriveRankedBands(bandsCount)
        )
    }
    
    static func derivePerformancesPerYear(
        _ numberOfPerformancesPerYear: [Int: Int],
        colorScheme: ColorScheme
    ) -> [(year: Int, count: Int, color: Color)] {
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
        
        return performancesPerYear
    }
    
    static func deriveRankedBands(_ bandsCount: [String: Int]) -> [(band: String, count: Int, rank: Int?)] {
        let topBands = bandsCount.sorted(by: {
            if $0.value != $1.value {
                return $0.value > $1.value
            }
            
            if $0.key.localizedStandardCompare($1.key) == .orderedAscending {
                return true
            }
            
            return false
        })
            .prefix(10)
        
        var rankedBands: [(String, Int, Int?)] = []
        var shows = 0
        for (index, element) in topBands.enumerated() {
            if shows != element.value {
                rankedBands.append((element.key, element.value, index + 1))
                shows = element.value
            } else {
                rankedBands.append((element.key, element.value, nil))
            }
        }
        
        return rankedBands
    }
    
}
