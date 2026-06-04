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
    
    /// Setting backed by user defaults: whether a CSV export should have a header.
    @AppStorage("ExportCSVHeader") private
    var exportCSVHeader: Bool = false
    
    /// Setting backed by user defaults: how to format partial attendandeces in CSV export.
    @AppStorage("ExportCSVPartialAttendanceFormat") private
    var exportCSVPartialAttendanceFormat: Repositories.PartialAttendanceFormat = .none
    
    /// Setting backed by user defaults: how to format dates in CSV export.
    @AppStorage("ExportCSVDateFormat") private
    var exportCSVDateFormat: DateTools.Format = .iso8601
    
    
    /// Whether the import file dialog is visible.
    @State private
    var showingImporter = false
    
    /// Whether the export file dialog is visible.
    @State private
    var showingExporter = false
    
    @State private
    var alert: AlertFactory.Kind?
    
    /// Progress of the import operation.
    @State private
    var importProgress: Progress?
    
    /// Data to export. Must be precomputed due to `@MainActor` requirements.
    @State private
    var exportData: Data?
    
    
    var body: some View {
        Form {
#if os(macOS)
            importSection
            exportSection
#endif
            
            Section(
                LocalizedStringResource(
                    "Data Management",
                    comment: "Section header for data management actions in settings"
                )
            ) {
                Button(LocalizedStringResource("Delete all data…", comment: "Button to delete all application data")) {
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
    
    @ViewBuilder
    var importSection: some View {
        Section(
            LocalizedStringResource("CSV Import", comment: "Section header for importing CSV files in settings")
        ) {
            Toggle(
                LocalizedStringResource(
                    "Ignore first line",
                    comment: "Toggle to skip the header row in imported CSV files"
                ),
                isOn: $ignoreFirstLineInCSV
            )
            .toggleStyle(.checkbox)
            
            Button(LocalizedStringResource("Import CSV file…", comment: "Button to import a CSV file")) {
                showingImporter = true
            }.fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [csvUTType],
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
    }
    
    
    @ViewBuilder
    var exportSection: some View {
        Section(
            LocalizedStringResource("CSV Export", comment: "Section header for export CSV files in settings")
        ) {
            Toggle(
                LocalizedStringResource(
                    "Add header line",
                    comment: "Toggle to add a header row in export CSV files"
                ),
                isOn: $exportCSVHeader
            )
            .toggleStyle(.checkbox)
            
            Picker(
                LocalizedStringResource(
                    "Date format",
                    comment: "Picker to select the date format for export CSV files"
                ),
                selection: $exportCSVDateFormat
            ) {
                Text(LocalizedStringResource(
                    "System Setting",
                    comment: "Date format selection: use date format from the system settings"
                )).tag(DateTools.Format.userSetting)
                
                Text(LocalizedStringResource(
                     "German",
                     comment: "Date format selection: use German date format"
                )).tag(DateTools.Format.german)
                
                Text(LocalizedStringResource(
                     "ISO 8601",
                     comment: "Date format selection: use ISO 8601 date format"
                )).tag(DateTools.Format.iso8601)
            }
            .pickerStyle(.radioGroup)
            
            Picker(
                LocalizedStringResource(
                    "Partial attendence format",
                    comment: "Picker to select the partial attendence format for export CSV files"
                ),
                selection: $exportCSVPartialAttendanceFormat
            ) {
                Text(LocalizedStringResource(
                    "None",
                    comment: "Selection to not export partial attendence"
                )).tag(Repositories.PartialAttendanceFormat.none)
                
                Text(LocalizedStringResource(
                    "Wrap band name in parenthesis",
                    comment: "Selection to export partial attendence in parenthesis"
                )).tag(Repositories.PartialAttendanceFormat.parenthesis)
            }
            .pickerStyle(.radioGroup)
            
            Button(LocalizedStringResource("Export CSV file…", comment: "Button to export a CSV file")) {
                do {
                    let string = try repositories.exportCSV(
                        includeHeader: self.exportCSVHeader,
                        dateFormat: self.exportCSVDateFormat,
                        partialAttendenceFormat: self.exportCSVPartialAttendanceFormat
                    )
                    self.exportData = Data(string.utf8)
                    self.showingExporter = true
                    
                } catch {
                    self.alert = .exportFailedWithError(error)
                }
            }.fileExporter(
                isPresented: $showingExporter,
                documents: [CSVDocument(data: exportData)],
                contentType: csvUTType
            ) {
                (result) in
                
                switch result {
                case .success:
                    break
                    
                case .failure(let error):
                    self.alert = .exportFailedWithError(error)
                }
            }
        }
    }
    
    
    func importCSV(at url: URL) {
        do {
            guard url.startAccessingSecurityScopedResource() else {
                alert = .importFailedWithMessage(message: String(
                    localized: "Failed to access the file.",
                    comment: "Error message shown when the app cannot access the selected file during import."
                ))
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
                alert = .importFailedWithMessage(message: String(
                    localized: "Empty CSV file.",
                    comment: "Error shown when the imported CSV file has no content."
                ))
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
            alert = .deleteAllDataFailed(error)
        }
    }
    
}


private
struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [csvUTType] }
    static var writableContentTypes: [UTType] { [csvUTType] }
    
    let data: Data?
    
    init(data: Data?) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        fatalError("Not supported")
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        if let data {
            return FileWrapper(regularFileWithContents: data)
        } else {
            // TODO: Provide an better error
            // (But this shouldn't be possible anyway…)
            throw POSIXError(.ENOENT)
        }
    }
}


nonisolated private
let csvUTType: UTType = UTType(filenameExtension: "csv")!


#Preview {
    let container = ModelContainer.mock()
    
    SettingsView()
        .environment(Repositories.mock(scenario: .empty, container: container))
}
