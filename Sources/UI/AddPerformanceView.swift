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
                        "Date",
                        selection: $date,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)
                    
                    TextField("Band", text: $bandName)
                    
                    TextField("Venue", text: $venueName)
                }
            }
            .padding()
            .navigationTitle("Add Performance")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
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
