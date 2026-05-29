//
//  PerformanceListView.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-27.
//

import SwiftUI
import SwiftData


/// Shows a list of performances.
struct PerformanceListView: View {
    
    /// The list of performances to show.
    @Query(
        sort: [
            SortDescriptor(\Performance.date, order: .forward),
            SortDescriptor(\Performance.sequence, order: .forward)
        ]
    )
    private var performances: [Performance]
    
    @State private
    var searchText: String = ""
    
    private
    var filteredPerformances: [Performance] {
        if searchText.isEmpty {
            return performances
        }
        
        return performances.filter {
            $0.band?.name.localizedStandardContains(searchText) == true
            || $0.venue?.name.localizedStandardContains(searchText) == true
        }
    }
    
    
    var body: some View {
#if os(iOS)
        ContentiOS(performances: filteredPerformances, searchText: $searchText)
#else
        ContentMacOS(performances: filteredPerformances, searchText: $searchText)
#endif
    }
    
}


#Preview {
    let container = ModelContainer.mock(scenario: .basic)
    PerformanceListView()
        .modelContainer(container)
        .environment(AppUIState())
}
