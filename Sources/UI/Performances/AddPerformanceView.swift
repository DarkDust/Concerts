//
//  AddPerformanceView.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-27.
//

import Foundation
import SwiftData
import SwiftUI


/// Main view to add a performance.
struct AddPerformanceView: View {
    
    /// Sheet dismissal.
    @Environment(\.dismiss)
    private var dismiss
    
    /// Repositories for data operations.
    @Environment(Repositories.self)
    private var repositories
    
    /// Date of performance.
    @State
    private var date: Date = Performance.normalizedConcertDate(.now)
    
    /// Name of the band playing.
    @State
    private var bandName: String = ""
    
    /// Name of the venue or event.
    @State
    private var venueName: String = ""
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        LocalizedStringResource(
                            "Date",
                            comment: "Title for the date picker when adding a new performance"
                        ),
                        selection: $date,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)
                    
                    TextField(
                        String(
                            localized: "Band",
                            comment: "Name of the band for which to add a performance"
                        ),
                        text: $bandName
                    )
                    .accessibilityIdentifier("band-name")
                    
                    TextField(
                        String(
                            localized: "Venue",
                            comment: "Name of the venue or event for which to add a performance"
                        ),
                        text: $venueName
                    )
                    .accessibilityIdentifier("venue-name")
                }
            }
            .padding()
            .navigationTitle(
                LocalizedStringResource(
                    "Add Performance",
                    comment: "Title of the view for adding a performance"
                )
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(
                        LocalizedStringResource(
                            "Cancel",
                            comment: "Label for cancelling adding a performance"
                        )
                    ) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(
                        LocalizedStringResource(
                            "Add Performance",
                            comment: "Button to add a performance"
                        )
                    ) {
                        addPerformance()
                    }
                    .disabled(
                        bandName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        || venueName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
            }
        }
    }
}


private
extension AddPerformanceView {
    
    func addPerformance() {
        do {
            let band = try repositories.bands.create(name: bandName)
            let venue = try repositories.venues.create(name: venueName)
            _ = try repositories.performances.add(band: band, venue: venue, date: date)
            dismiss()
        } catch {
            // TODO: Present alert
        }
    }
    
}


#Preview {
    AddPerformanceView()
        .modelContainer(ModelContainer.mock())
}
