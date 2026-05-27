//
//  Repositories+DeleteEverything.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-27.
//

import Foundation
import SwiftData


extension Repositories {
    
    /// Delete all entries.
    func deleteEverything() throws {
        try self.performances.deleteEverything()
        try self.venues.deleteEverything()
        try self.bands.deleteEverything()
    }
    
}
