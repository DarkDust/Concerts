//
//  Item.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
