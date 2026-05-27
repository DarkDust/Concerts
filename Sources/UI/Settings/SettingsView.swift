//
//  SettingsView.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-27.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import SwiftData


struct SettingsView: View {
    
    /// SwiftData operations.
    @Environment(Repositories.self) private
    var repositories: Repositories
    
    /// Setting backed by user defaults: whether the first line of a CSV should be ignored because
    /// it contains the header.
    @AppStorage("IgnoreFirstLineInCSV") private
    var ignoreFirstLineInCSV: Bool = false
    
    /// Whether the file dialog is visible.
    @State private
    var showingImporter = false
    
    /// Error message for an alert.
    @State private
    var errorMessage: String?
    
    /// Status message for an alert.
    @State private
    var statusMessage: String?
    
    /// Progress of the import operation.
    @State private
    var importProgress: Progress?
    
    /// Whether the delete confirmation alert is shown.
    @State private
    var showingDeleteAlert = false
    
    
    var body: some View {
        Form {
#if os(macOS)
            Section(
                LocalizedStringResource("CSV Import", comment: "Settings section about importing CSV files")
            ) {
                Toggle(
                    LocalizedStringResource("Ignore first line", comment: "Checkbox to skip the header row in CSV files"),
                    isOn: $ignoreFirstLineInCSV
                )
                .toggleStyle(.checkbox)
                
                Button(LocalizedStringResource("Import CSV file…", comment: "Button to start the CSV import")) {
                    showingImporter = true
                }.fileImporter(
                    isPresented: $showingImporter,
                    allowedContentTypes: [UTType(filenameExtension: "csv")!],
                    allowsMultipleSelection: false
                ) {
                    (result) in
                    
                    switch result {
                    case .success(let urls):
                        guard let url = urls.first else {
                            return
                        }
                        importCSV(at: url)
                        
                    case .failure:
                        break
                    }
                }
            }
#endif
            
            Section(
                LocalizedStringResource("Data Management", comment: "Settings section about managing the app's data")
            ) {
                Button(LocalizedStringResource("Delete all data…", comment: "Button to delete all app data")) {
                    showingDeleteAlert = true
                }
            }
        }
        .formStyle(.grouped)
#if os(macOS)
        .padding(20)
        .frame(width: 480)
        .fixedSize(horizontal: false, vertical: true)
#endif
        
        .alert(
            "Import Failed",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )
        ) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "")
        }
        
        .alert(
            "Import Complete",
            isPresented: Binding(
                get: { statusMessage != nil },
                set: { if !$0 { statusMessage = nil } }
            )
        ) {
            Button("OK") { }
        } message: {
            Text(statusMessage ?? "")
        }
        
        .alert(
            "Delete All Data?",
            isPresented: $showingDeleteAlert
        ) {
            Button("Delete", role: .destructive) {
                deleteEverything()
            }
            
            Button("Cancel", role: .cancel) { }
            
        } message: {
            Text("This action cannot be undone.")
        }
        
        .sheet(isPresented: Binding(
            get: { importProgress != nil },
            set: { if !$0 { importProgress = nil } }
        )) {
            if let importProgress {
                ImportProgressSheet(progress: importProgress)
            } else {
                EmptyView()
            }
        }
    }
    
}


#if os(macOS)
private
extension SettingsView {
    
    func importCSV(at url: URL) {
        do {
            guard url.startAccessingSecurityScopedResource() else {
                errorMessage = String(localized: "Failed to access the file.")
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            let data = try Data(contentsOf: url)
            let content = String(data: data, encoding: .utf8) ?? ""
            var lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
            if ignoreFirstLineInCSV, !lines.isEmpty {
                _ = lines.removeFirst()
            }
            
            guard !lines.isEmpty else {
                errorMessage = String(localized: "Empty CSV file.")
                return
            }
            
            self.importProgress = repositories.importCSV(lines: lines) {
                self.importProgress = nil
                self.statusMessage = $0
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
}
#endif


private
extension SettingsView {
    
    func deleteEverything() {
        do {
            try repositories.deleteEverything()
        } catch {
            // TODO: Will show a wrong title for the alert (import).
            errorMessage = error.localizedDescription
        }
    }
    
}


#Preview {
    let container = ModelContainer.mock()
    
    SettingsView()
        .environment(Repositories.mock(scenario: .empty, container: container))
}
