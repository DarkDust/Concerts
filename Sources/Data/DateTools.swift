//
//  DateTools.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-06-04.
//

import Foundation

struct DateTools {
    
    /// Date format to use.
    enum Format: String {
        /// German date format with leading zero, like 23.04.2026.
        case german
        
        /// Date format according to current user settings.
        case userSetting
        
        /// ISO 8601 date format, like 2026-04-23.
        case iso8601
    }
    
    /// Date formatter for German dates (because that's what my CSV files use).
    @MainActor
    static let germanDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    /// Date formatter for dates according to the current user settings.
    @MainActor
    static let userSettingDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.isLenient = true
        return formatter
    }()
    
    /// Date formatter for ISO 8601 dates.
    @MainActor
    static let isoDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        return formatter
    }()
    
    
    /// Attempts to parse the date according to the given format. If none is given, all supported formats are tried.
    @MainActor
    static func parse(string: String, format: Format? = nil) -> Date? {
        switch format {
        case .none:
            if let result = germanDateFormatter.date(from: string) { return result }
            if let result = userSettingDateFormatter.date(from: string) { return result }
            if let result = isoDateFormatter.date(from: string) { return result }
            return nil
            
        case .german:
            return germanDateFormatter.date(from: string)
            
        case .userSetting:
            return userSettingDateFormatter.date(from: string)
            
        case .iso8601:
            return isoDateFormatter.date(from: string)
        }
    }
    
    
    /// Convert a date to a string in the given format.
    @MainActor
    static func format(date: Date, as format: Format) -> String {
        switch format {
        case .german:
            return germanDateFormatter.string(from: date)
        case .userSetting:
            return userSettingDateFormatter.string(from: date)
        case .iso8601:
            return isoDateFormatter.string(from: date)
        }
    }
    
}
