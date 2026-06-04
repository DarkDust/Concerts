//
//  PerformanceListView.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-06-04.
//

import Foundation
import SwiftUI
import SwiftData


struct PerformanceListView: View {
    
    /// Which columns to show.
    struct Columns: OptionSet {
        let rawValue: Int
        
        /// Show the band column.
        static let band =  Columns(rawValue: 1 << 0)
        
        /// Show the venue column.
        static let venue =  Columns(rawValue: 1 << 1)

        /// Show the date column.
        static let date =  Columns(rawValue: 1 << 2)
        
        /// Show all known columns.
        static let all: Columns = [.band, .venue, .date]
    }
    
    
    /// List of performances to show.
    let performances: [Performance]
    
    /// Which columns to show.
    let columns: Columns
    
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
        ContentiOS(
            performances: filteredPerformances,
            columns: columns,
            searchText: $searchText
        )
#else
        ContentMacOS(
            performances: filteredPerformances,
            columns: columns,
            searchText: $searchText
        )
#endif
    }
}


#Preview("All Columns") {
    let container = ModelContainer.mock(scenario: .basic)
    // swiftlint:disable:next force_try
    let performances = try! container.mainContext.fetch(FetchDescriptor<Performance>())
    
    PerformanceListView(performances: performances, columns: .all)
        .modelContainer(container)
        .environment(Repositories(context: container.mainContext))
        .environment(AppUIState())
}

#Preview("Without Band") {
    let container = ModelContainer.mock(scenario: .basic)
    // swiftlint:disable:next force_try
    let performances = try! container.mainContext.fetch(FetchDescriptor<Performance>())
    
    PerformanceListView(performances: performances, columns: [.venue, .date])
        .modelContainer(container)
        .environment(Repositories(context: container.mainContext))
        .environment(AppUIState())
}

#Preview("Without Venue") {
    let container = ModelContainer.mock(scenario: .basic)
    // swiftlint:disable:next force_try
    let performances = try! container.mainContext.fetch(FetchDescriptor<Performance>())
    
    PerformanceListView(performances: performances, columns: [.band, .date])
        .modelContainer(container)
        .environment(Repositories(context: container.mainContext))
        .environment(AppUIState())
}
