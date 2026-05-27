//
//  PerformanceList.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-27.
//

import SwiftUI
import SwiftData


struct PerformanceList: View {
    
    @Query(
        sort: [
            SortDescriptor(\Performance.date, order: .forward),
            SortDescriptor(\Performance.sequence, order: .forward)
        ]
    )
    private var performances: [Performance]
    
    var body: some View {
        Table(performances) {
            TableColumn("Date") {
                Text($0.date, format: .dateTime.year().month().day())
            }
            
            TableColumn("Band") {
                Text($0.band?.name ?? "Unknown")
            }
            
            TableColumn("Venue") {
                Text($0.venue?.name ?? "Unknown")
            }
        }
    }
    
}


#Preview {
    let container = ModelContainer.mock(scenario: .basic)
    PerformanceList()
        .modelContainer(container)
}
