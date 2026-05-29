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
    @Environment(\.dismiss) private
    var dismiss
    
    /// Repositories for data operations.
    @Environment(Repositories.self) private
    var repositories
    
    /// Date of performance.
    @State private
    var date: Date = Performance.normalizedConcertDate(.now)
    
    /// Name of the band playing.
    @State private
    var bandName: String = ""
    
    /// Suggestions for the band name.
    @State private
    var bandNameSuggestions: [Band] = []
    
    /// Name of the venue or event.
    @State private
    var venueName: String = ""
    
    /// Suggestions for the venue name.
    @State private
    var venueNameSuggestions: [Venue] = []
    
    /// Indicates whether the performance was only partially attended.
    @State private
    var partialAttendance: Bool = false
    
    /// Used to move input focus to the band name when sheet is presented.
    @FocusState private
    var focusedField: Field?
    
    /// Alert to show.
    @State private
    var alert: AlertFactory.Kind?
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        LocalizedStringResource(
                            "Date",
                            comment: "Label for the date picker when adding a new performance"
                        ),
                        selection: $date,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)
                    
                    bandNameField
                    
                    venueNameField
                    
                    Toggle(
                        LocalizedStringResource(
                            "Partial attendance",
                            comment: "Label for marking the performance as only partially attended"
                        ),
                        isOn: $partialAttendance
                    )
                }
            }
            .padding()
#if os(macOS)
            .navigationTitle(
                LocalizedStringResource(
                    "Add Performance",
                    comment: "Navigation title for the view to add a new performance"
                )
            )
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(
                        LocalizedStringResource(
                            "Cancel",
                            comment: "Button label to cancel adding a performance"
                        )
                    ) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(
                        LocalizedStringResource(
                            "Add Performance",
                            comment: "Button label to add a performance"
                        )
                    ) {
                        addPerformance()
                    }
                    .accessibilityIdentifier("add-performance")
                    .disabled(
                        bandName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        || venueName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
            }
            .alert(kind: $alert)
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
            _ = try repositories.performances.add(
                band: band,
                venue: venue,
                date: date,
                partialAttendance: partialAttendance
            )
            dismiss()
        } catch {
            alert = .addPerformanceFailed(error)
        }
    }
    
    
    @ViewBuilder
    var bandNameField: some View {
        AutoSuggestTextField<Band>(
            String(
                localized: "Band",
                comment: "Label for the text field to enter the band name when adding a performance"
            ),
            text: $bandName,
            suggestions: {
                guard !$0.isEmpty else {
                    return []
                }
                do {
                    let results = try repositories.bands.search(query: $0)
                    if results.count == 1, results.first?.name == $0 {
                        return []
                    } else {
                        return results.sorted {
                            $0.name.localizedStandardCompare($1.name) == .orderedAscending
                        }
                    }
                } catch {
                    return []
                }
            },
            suggestionLabel: { $0.name }
        )
        .accessibilityIdentifier("band-name")
        .focused($focusedField, equals: .bandName)
    }
    
    
    @ViewBuilder
    var venueNameField: some View {
        AutoSuggestTextField<Venue>(
            String(
                localized: "Venue",
                comment: "Label for the text field to enter the venue or event name when adding a performance"
            ),
            text: $venueName,
            suggestions: {
                guard !$0.isEmpty else {
                    return []
                }
                do {
                    let results = try repositories.venues.search(query: $0)
                    if results.count == 1, results.first?.name == $0 {
                        return []
                    } else {
                        return results.sorted {
                            $0.name.localizedStandardCompare($1.name) == .orderedAscending
                        }
                    }
                } catch {
                    return []
                }
            },
            suggestionLabel: { $0.name }
        )
        .accessibilityIdentifier("venue-name")
    }
    
}


#Preview {
    AddPerformanceView()
        .modelContainer(ModelContainer.mock())
}
