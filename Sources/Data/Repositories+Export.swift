//
//  Repositories+Export.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-06-04.
//

import Foundation

extension Repositories {
    
    /// How to format performances with partial attendance.
    enum PartialAttendanceFormat: String {
        /// Do not format partially attended performance.
        case none
        
        /// Wrap the band name in parenthesis.
        case parenthesis
    }
    
    
    /// Export all performances as CSV.
    @MainActor
    func exportCSV(
        includeHeader: Bool,
        dateFormat: DateTools.Format,
        partialAttendenceFormat: PartialAttendanceFormat
    ) throws -> String {
        let performances = try self.performances.fetchAll()
        let lines = performances.map {
            csvLine(for: $0, dateFormat: dateFormat, partialAttendenceFormat: partialAttendenceFormat)
        }
        
        if includeHeader {
            let header = [
                "Band",
                "Datum",
                "Location"
            ].joined(separator: Self.csvDelimiter)
            
            return header + "\n" + lines.joined(separator: "\n")
            
        } else {
            return lines.joined(separator: "\n")
        }
    }
    
}


private
extension Repositories {
    
    static let csvDelimiter = ";"
    
    func csvLine(
        for performance: Performance,
        dateFormat: DateTools.Format,
        partialAttendenceFormat: PartialAttendanceFormat
    ) -> String {
        let rawBandName = performance.band?.name ?? "?"
        let bandName: String
        switch partialAttendenceFormat {
        case .none:
            bandName = rawBandName
            
        case .parenthesis:
            if performance.partialAttendance {
                bandName = "(" + rawBandName + ")"
            } else {
                bandName = rawBandName
            }
        }
        
        let parts = [
            bandName,
            DateTools.format(date: performance.date, as: dateFormat),
            performance.venue?.name ?? "?",
        ]
        
        return parts.joined(separator: Self.csvDelimiter)
    }
    
}
