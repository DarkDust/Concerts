//
//  PerformanceListView.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-27.
//

import SwiftUI
import SwiftData


struct PerformanceListView: View {
    
    @Query(
        sort: [
            SortDescriptor(\Performance.date, order: .forward),
            SortDescriptor(\Performance.sequence, order: .forward)
        ]
    )
    private var performances: [Performance]
    
    var body: some View {
        #if os(iOS)
        ContentiOS(performances: performances)
        #else
        ContentMacOS(performances: performances)
        #endif
    }
    
}


private
extension PerformanceListView {
    
    struct ContentMacOS: View {
        let performances: [Performance]
        
        var body: some View {
            Table(performances) {
                TableColumn("Band") {
                    Text($0.band?.name ?? "Unknown")
                }
                
                TableColumn("Venue") {
                    Text($0.venue?.name ?? "Unknown")
                }
                
                TableColumn("Date") {
                    Text($0.date, format: .dateTime.year().month().day())
                }
                .width(100)
            }
        }
    }
    
    struct ContentiOS: View {
        let performances: [Performance]
        
        var body: some View {
            List(performances) {
                (performance) in
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(performance.band?.name ?? "Unknown")
                        .font(.headline)
                    
                    HStack() {
                        Text(performance.venue?.name ?? "Unknown")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(
                            performance.date,
                            format: .dateTime.year().month().day()
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
}


#Preview {
    let container = ModelContainer.mock(scenario: .basic)
    PerformanceListView()
        .modelContainer(container)
}
