//
//  DirectoryDetailView.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-31.
//

import Foundation
import SwiftUI
import SwiftData


/// Shows which performances were visited for a given band or venue.
struct DirectoryDetailView: View {
    
    /// Band or venue to present data for.
    enum Value {
        case band(Band)
        case venue(Venue)
    }
    
    /// Band or venue to present data for.
    let value: Value
    
    /// Padding between date and text, scaling with the dynamic text size.
    @ScaledMetric private
    var cellPadding: CGFloat = 20
    
    /// Horizontal size class to decide how to present the band or venue name.
    @Environment(\.horizontalSizeClass) private
    var horizontalSizeClass
    
    /// Current color scheme.
    @Environment(\.colorScheme) private
    var colorScheme
    
    
    var body: some View {
        let performances = value.performances
        
        VStack {
            if horizontalSizeClass != .compact {
                Text(value.name)
                    .font(.title)
                    .padding(.bottom)
            }
            
            ScrollView {
                Grid(alignment: .leading, horizontalSpacing: cellPadding) {
                    ForEach(performances.indices, id: \.self) {
                        (index) in
                        
                        let performance = performances[index]
                        
                        
                        if index > 0 {
                            Divider()
                                .gridCellUnsizedAxes(.horizontal)
                        }
                        
                        GridRow {
                            Text(
                                performance.date,
                                format: .dateTime.year().month().day()
                            )
                            .foregroundStyle(performance.date.yearColor(colorScheme: colorScheme))
                            .gridColumnAlignment(.trailing)
                            
                            Text(value.text(for: performance))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .navigationTitle(value.name)
            .toolbarTitleDisplayMode(.inline)
        }
        .padding()
    }
    
}


private
extension DirectoryDetailView.Value {
    
    var name: String {
        switch self {
        case .band(let band): return band.name
        case .venue(let venue): return venue.name
        }
    }
    
    var performances: [Performance] {
        switch self {
        case .band(let band):
            guard let performances = band.performances else { return [] }
            return performances.sorted {
                if $0.date == $1.date { return $0.sequence < $1.sequence }
                return $0.date < $1.date
            }
            
        case .venue(let venue):
            guard let performances = venue.performances else { return [] }
            return performances.sorted {
                if $0.date == $1.date { return $0.sequence < $1.sequence }
                return $0.date < $1.date
            }
        }
    }
    
    func text(for performance: Performance) -> String {
        switch self {
        case .band:
            return performance.venue?.name ?? String(
                localized: "Unknown",
                comment: "Displayed when the venue name is unknown"
            )
            
        case .venue:
            return performance.band?.name ?? String(
                localized: "Unknown",
                comment: "Displayed when the band name is unknown"
            )
        }
    }
    
}


#Preview("Band") {
    let container = ModelContainer.mock(scenario: .bandPerformances)
    // swiftlint:disable:next force_try
    let bands = try! container.mainContext.fetch(FetchDescriptor<Band>())
    
    DirectoryDetailView(value: .band(bands.first!))
        .modelContainer(container)
}

#Preview("Venue") {
    let container = ModelContainer.mock(scenario: .venuePerformances)
    // swiftlint:disable:next force_try
    let venues = try! container.mainContext.fetch(FetchDescriptor<Venue>())
    
    DirectoryDetailView(value: .venue(venues.first!))
        .modelContainer(container)
}
