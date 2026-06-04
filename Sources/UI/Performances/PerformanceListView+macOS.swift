//
//  PerformanceListView+macOS.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-29.
//

#if os(macOS)
import Foundation
import SwiftUI
import SwiftData


extension PerformanceListView {
    
    /// List view for macOS using a table.
    struct ContentMacOS: View {
        /// List of performances to show.
        let performances: [Performance]
        
        /// Which columns to render.
        let columns: PerformanceListView.Columns
        
        
        @Binding
        var searchText: String
        
        @State private
        var selection: Performance.ID?
        
        @Environment(Repositories.self) private
        var repositories: Repositories
        
        @Environment(AppUIState.self) private
        var uiState: AppUIState
        
        @Environment(\.colorScheme) private
        var colorScheme: ColorScheme
        
        @State private
        var alert: AlertFactory.Kind?
        
        
        var body: some View {
            @Bindable var uiState = uiState
            
            Table(performances, selection: $selection) {
                if columns == .all {
                    bandColumn
                    venueColumn
                    dateColumn
                    
                } else {
                    // Not all columns visible. Date should be first as that has more importance in this view mode.
                    if columns.contains(.date) {
                        dateColumn
                    }
                    
                    if columns.contains(.band) {
                        bandColumn
                    }
                    
                    if columns.contains(.venue) {
                        venueColumn
                    }
                }
            }
            .background(TableScroller(performances: performances))
            .alert(kind: $alert)
            .toolbar {
                ToolbarItem {
                    SearchField(searchText: $searchText, focus: $uiState.requestSearchFocus)
                        .frame(width: 200)
                }
                
                ToolbarSpacer(.fixed)
                
                ToolbarItem {
                    Button(action: editItem) {
                        Label(
                            LocalizedStringResource(
                                "Edit Performance",
                                comment: "Toolbar button title: edit a selected performance"
                            ),
                            systemImage: "square.and.pencil"
                        )
                    }
                    .accessibilityIdentifier("edit-item")
                    .disabled(selection == nil)
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label(
                            LocalizedStringResource(
                                "Add Performance",
                                comment: "Toolbar button title: add a new performance"
                            ),
                            systemImage: "plus"
                        )
                    }
                    .accessibilityIdentifier("add-item")
                }
            }
            .onDeleteCommand {
                guard
                    let selection,
                    let performance = performances.first(where: { $0.id == selection })
                else {
                    return
                }
                
                do {
                    try repositories.delete(performance)
                } catch {
                    alert = .deletePerformanceFailed(error)
                }
            }
        }
    }
    
}


private
extension PerformanceListView.ContentMacOS {
    
    var bandColumn: TableColumn<Performance, Never, some View, Text> {
        TableColumn(
            LocalizedStringResource("Band", comment: "Table column header for band name")
        ) {
            (performance: Performance) in
            Text(
                performance.band?.name ?? String(
                    localized: "Unknown",
                    comment: "Displayed when the band name is unknown"
                )
            ).partialAttendance(performance.partialAttendance)
        }
    }
    
    var venueColumn: TableColumn<Performance, Never, some View, Text> {
        TableColumn(
            LocalizedStringResource("Venue", comment: "Table column header for venue name")
        ) {
            (performance: Performance) in
            Text(performance.venue?.name ?? String(
                localized: "Unknown",
                comment: "Displayed when the venue name is unknown"
            ))
            .partialAttendance(performance.partialAttendance)
        }
    }
    
    var dateColumn: TableColumn<Performance, Never, some View, Text> {
        TableColumn(
            LocalizedStringResource("Date", comment: "Table column header for performance date"),
        ) {
            (performance: Performance) in
            Text(performance.date, format: .dateTime.year().month().day())
                .monospacedDigit()
                .foregroundStyle(performance.date.yearColor(colorScheme: colorScheme))
                .partialAttendance(performance.partialAttendance, useOpacity: true)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .width(100)
    }
    
    func addItem() {
        uiState.presentedSheet = .addPerformance
    }
    
    func editItem() {
        if let selection, let performance = performances.first(where: { $0.id == selection }) {
            uiState.presentedSheet = .editPerformance(performance)
        }
    }
    
}


/// Stupid hack to find the `NSTableView` and scroll it to the bottom.
///
/// SwiftUI's `Table` is supposed to work with a `ScrollViewReader`/`ScrollViewProxy`, and legend has it that it
/// worked. But it does not work in macOS 26!
///
/// The `Table` is still backed by a `NSTableView`, thankfully, so what this hack does is walking the whole view
/// hierarychy of the window to find the table, and then scrolls it to the bottom.
///
/// Obviously this will fail when:
/// * Apple does not use a `NSTableView` for `Table` any more.
/// * You have more than one `Table` in your window.
///
/// Another downside is that you see the table in its unscrolled position for a short time.
private
struct TableScroller: NSViewRepresentable {
    /// Dummy property: once the performances change (we've added a performance), also scroll to the bottom.
    var performances: [Performance]
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        scrollToBottom(view: view)
        return view
    }
    
    func updateNSView(_ view: NSView, context: Context) {
        scrollToBottom(view: view)
    }
    
    private
    func scrollToBottom(view: NSView) {
        DispatchQueue.main.async {
            let root = findRootView(of: view)
            guard let tableView = findTableView(in: root) else { return }
            
            let lastRow = tableView.numberOfRows - 1
            guard lastRow >= 0 else { return }
            
            tableView.scrollRowToVisible(lastRow)
        }
    }
    
    private
    func findTableView(in view: NSView) -> NSTableView? {
        if let table = view as? NSTableView {
            return table
        }
        
        for subview in view.subviews {
            if let found = findTableView(in: subview) {
                return found
            }
        }
        
        return nil
    }
    
    private
    func findRootView(of view: NSView) -> NSView {
        var cursor = view
        while let superview = cursor.superview {
            cursor = superview
        }
        return cursor
    }
    
}
#endif
