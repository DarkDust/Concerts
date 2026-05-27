//
//  Repositories+Import.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-27.
//

import Foundation

extension Repositories {
    
    @MainActor
    func importCSV(lines: [String], completion: @escaping @MainActor (String) -> Void) -> Progress {
        let progress = Progress(totalUnitCount: Int64(lines.count))
        
        Task {
            var successCount: Int = 0
            
            for (index, line) in lines.enumerated() {
                progress.completedUnitCount = Int64(index + 1)
                if importCSVLine(line) { successCount += 1 }
                await Task.yield()
            }
            
            if successCount == lines.count {
                completion(String(localized: "Imported \(successCount) lines."))
            } else {
                completion(String(localized: "Imported \(successCount) of \(lines.count) lines."))
            }
        }
        
        return progress
    }
    
}


private
extension Repositories {
    
    /// Date formatter for German dates (because that's what my CSV files use).
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    
    @MainActor
    func importCSVLine(_ line: String) -> Bool {
        let parts = line.split(separator: ";").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard parts.count == 3 else {
            NSLog("⚠️ Invalid line: \(line)")
            return false
        }
        
        let bandName = parts[0]
        let venueName = parts[2]
        let dateString = parts[1]
        
        guard let date = Self.dateFormatter.date(from: dateString) else {
            NSLog("⚠️ Invalid date '\(dateString)' in line: \(line)")
            return false
        }
        
        do {
            let band = try self.bands.create(name: bandName)
            let venue = try self.venues.create(name: venueName)
            _ = try self.performances.add(band: band, venue: venue, date: date)
            return true
            
        } catch {
            NSLog("⚠️ Error while importing: \(error)")
            return false
        }
    }
    
}
