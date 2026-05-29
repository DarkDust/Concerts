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
    
    @State private
    var alert: AlertFactory.Kind?
    
    /// Progress of the import operation.
    @State private
    var importProgress: Progress?
    
    
    var body: some View {
        Form {
#if os(macOS)
            Section(
                LocalizedStringResource("CSV Import", comment: "Settings section about importing CSV files")
            ) {
                Toggle(
                    LocalizedStringResource(
                        "Ignore first line",
                        comment: "Checkbox to skip the header row in CSV files"
                    ),
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
                    self.alert = .confirmDeleteAllData(commit: {
                        deleteEverything()
                    })
                }
            }
        }
        .formStyle(.grouped)
#if os(macOS)
        .padding(20)
        .frame(width: 480)
        .fixedSize(horizontal: false, vertical: true)
#endif
        .alert(kind: $alert)
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
                alert = .importFailedWithMessage(message: String(localized: "Failed to access the file."))
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
                alert = .importFailedWithMessage(message: String(localized: "Empty CSV file."))
                return
            }
            
            self.importProgress = repositories.importCSV(lines: lines) {
                self.importProgress = nil
                self.alert = .importCompleted(message: $0)
            }
            
        } catch {
            alert = .importFailedWithError(error)
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
            alert = .importFailedWithError(error)
        }
    }
    
}


#Preview {
    let container = ModelContainer.mock()
    
    SettingsView()
        .environment(Repositories.mock(scenario: .empty, container: container))
}
