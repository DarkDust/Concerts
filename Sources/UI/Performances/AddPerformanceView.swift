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
    
    /// Known fields.
    enum Field {
        case bandName
    }
    
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
    
    /// Suggestions for the band name.
    @State
    private var bandNameSuggestions: [Band] = []
    
    /// Name of the venue or event.
    @State
    private var venueName: String = ""
    
    /// Suggestions for the venue name.
    @State
    private var venueNameSuggestions: [Venue] = []
    
    /// Used to move input focus to the band name when sheet is presented.
    @FocusState
    private var focusedField: Field?
    
    
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
                    
                    bandNameField
                    
                    venueNameField
                }
            }
            .padding()
            #if os(macOS)
                .navigationTitle(
                    LocalizedStringResource(
                        "Add Performance",
                        comment: "Title of the view for adding a performance"
                    )
                )
            #endif
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
            .onAppear {
                focusedField = .bandName
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
    
    
    @ViewBuilder
    var bandNameField: some View {
        TextField(
            String(
                localized: "Band",
                comment: "Name of the band for which to add a performance"
            ),
            text: $bandName
        )
        .accessibilityIdentifier("band-name")
        .onChange(of: bandName) {
            (_, newValue) in
            
            guard !newValue.isEmpty else {
                bandNameSuggestions = []
                return
            }
            do {
                bandNameSuggestions = try repositories.bands.search(query: newValue)
            } catch {
                bandNameSuggestions = []
            }
        }
        .textInputSuggestions {
            ForEach(bandNameSuggestions) {
                (band) in
                
                Text(band.name)
                    .textInputCompletion(band.name)
            }
        }
        .focused($focusedField, equals: .bandName)
    }
    
    
    @ViewBuilder
    var venueNameField: some View {
        TextField(
            String(
                localized: "Venue",
                comment: "Name of the venue or event for which to add a performance"
            ),
            text: $venueName
        )
        .accessibilityIdentifier("venue-name")
        .onChange(of: venueName) {
            (_, newValue) in
            
            guard !newValue.isEmpty else {
                venueNameSuggestions = []
                return
            }
            do {
                venueNameSuggestions = try repositories.venues.search(query: newValue)
            } catch {
                venueNameSuggestions = []
            }
        }
        .textInputSuggestions {
            ForEach(venueNameSuggestions) {
                (venue) in
                
                Text(venue.name)
                    .textInputCompletion(venue.name)
            }
        }
    }
    
}


#Preview {
    AddPerformanceView()
        .modelContainer(ModelContainer.mock())
}
