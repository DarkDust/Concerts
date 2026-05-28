//
//  PerformanceListView.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-27.
//

import SwiftUI
import SwiftData


/// Shows a list of performances.
struct PerformanceListView: View {
    
    /// The list of performances to show.
    @Query(
        sort: [
            SortDescriptor(\Performance.date, order: .forward),
            SortDescriptor(\Performance.sequence, order: .forward)
        ]
    )
    private var performances: [Performance]
    
    
    var body: some View {
        #if os(iOS)
        ContentiOS(performances: performances)
        #else
        ContentMacOS(performances: performances)
        #endif
    }
    
}


#if os(macOS)
private
extension PerformanceListView {
    
    /// List view for macOS using a table.
    struct ContentMacOS: View {
        let performances: [Performance]
        
        var body: some View {
            Table(performances) {
                TableColumn(
                    LocalizedStringResource("Band", comment: "Table column title: Band name")
                ) {
                    Text(
                        $0.band?.name ?? String(localized: "Unknown", comment: "Unknown band name")
                    ).partialAttendance($0.partialAttendance)
                }
                
                TableColumn(
                    LocalizedStringResource("Venue", comment: "Table column title: Venue name")
                ) {
                    Text($0.venue?.name ?? String(localized: "Unknown", comment: "Unknown venue name"))
                        .partialAttendance($0.partialAttendance)
                }
                
                TableColumn(
                    LocalizedStringResource("Date", comment: "Table column title: Performance date")
                ) {
                    Text($0.date, format: .dateTime.year().month().day())
                        .partialAttendance($0.partialAttendance)
                }
                .width(100)
            }
            .background(TableScroller(performances: performances))
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


#if os(iOS)
private
extension PerformanceListView {
    
    /// List view for iOS using a simple list.
    struct ContentiOS: View {
        let performances: [Performance]
        
        @Environment(AppUIState.self) private
        var appUIState: AppUIState
        
        
        var body: some View {
            ZStack(alignment: .bottomTrailing) {
                ListView(performances: performances)
                
                Button {
                    appUIState.presentedSheet = .addPerformance
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .clipShape(Circle())
                .padding()
            }
        }
    }
    
    
    /// Helper view: the actual iOS list view implementation.
    struct ListView: View {
        
        let performances: [Performance]
        
        var body: some View {
            ScrollViewReader {
                (proxy) in
                
                List(performances) {
                    (performance) in
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(performance.band?.name ?? String(localized: "Unknown", comment: "Unknown band name"))
                            .font(.headline)
                            .partialAttendance(performance.partialAttendance)
                        
                        HStack {
                            Text(performance.venue?.name ?? String(localized: "Unknown", comment: "Unknown venue name"))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .partialAttendance(performance.partialAttendance)
                            
                            Spacer()
                            
                            Text(
                                performance.date,
                                format: .dateTime.year().month().day()
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .partialAttendance(performance.partialAttendance)
                        }
                    }
                    .id(performance)
                }
                .safeAreaInset(edge: .bottom) {
                    // Empty transparent inset
                    Color.clear
                        .frame(height: 80)
                }
                .onAppear {
                    if let last = performances.last {
                        // Scroll to bottom. The anchor point is "lower" than .bottom to absolutely scroll to the
                        // bottom. With .bottom, there are a few pixels left to scroll.
                        proxy.scrollTo(last, anchor: UnitPoint(x: 0.5, y: 1.5))
                    }
                }
            }
        }
    }
    
}
#endif


private
struct PartialAttendanceModifier: ViewModifier {
    
    let partialAttendance: Bool
    
    func body(content: Content) -> some View {
        if partialAttendance {
            content
                .foregroundStyle(.secondary)
                .italic()
        } else {
            content
        }
    }
    
}


private
extension View {

    func partialAttendance(
        _ partialAttendance: Bool
    ) -> some View {
        modifier(
            PartialAttendanceModifier(
                partialAttendance: partialAttendance
            )
        )
    }
    
}


#Preview {
    let container = ModelContainer.mock(scenario: .basic)
    PerformanceListView()
        .modelContainer(container)
        .environment(AppUIState())
}
