//
//  NameEditView.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-06-28.
//

import Foundation
import SwiftUI

struct NameEditView: View {
    
    /// Band or venue to present data for.
    let value: DirectoryDetailView.Value
    
    @Binding
    var isEditing: Bool
    
    @State private
    var editedName: String = ""
    
    @FocusState private
    var nameIsFocused: Bool
    
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $editedName)
                    .focused($nameIsFocused)
            }
            .padding()
            .navigationTitle("Edit Name")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isEditing = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        switch value {
                        case .band(let band):
                            band.name = editedName
                        case .venue(let venue):
                            venue.name = editedName
                        }
                        isEditing = false
                    }
                    .disabled(editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            editedName = value.name
            nameIsFocused = true
        }
    }
    
}
