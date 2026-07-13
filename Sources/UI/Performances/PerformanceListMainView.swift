//
//  PerformanceListMainView.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-27.
//

import SwiftUI
import SwiftData


/// Shows a list of performances.
struct PerformanceListMainView: View {
    
    /// The list of performances to show.
    @Query(
        sort: [
            SortDescriptor(\Performance.date, order: .forward),
            SortDescriptor(\Performance.sequence, order: .forward)
        ]
    )
    private
    var performances: [Performance]
    
    var body: some View {
        PerformanceListView(
            performances: performances,
            columns: .all,
            showSearch: true,
            showsImageBackground: true
        )
    }
    
}


#Preview {
    let container = ModelContainer.mock(scenario: .basic)
    PerformanceListMainView()
        .modelContainer(container)
        .environment(Repositories(context: container.mainContext))
        .environment(AppUIState())
}
