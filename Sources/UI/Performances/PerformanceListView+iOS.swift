//
//  PerformanceListView+iOS.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-29.
//

#if os(iOS)
import Foundation
import SwiftUI

extension PerformanceListView {
    
    /// List view for iOS using a simple list.
    struct ContentiOS: View {
        let performances: [Performance]
        
        let columns: PerformanceListView.Columns
        
        @Binding
        var searchText: String
        
        @Environment(AppUIState.self) private
        var appUIState: AppUIState
        
        @State private
        var searchFocused: Bool = false
        
        
        var body: some View {
            ZStack(alignment: .bottom) {
                WrapperView(performances: performances, columns: columns)
                    .onTapGesture {
                        // Tap outside the search bar should dismiss it.
                        searchFocused = false
                    }
                
                HStack {
                    SearchField(searchText: $searchText, focus: $searchFocused)
                        .padding(.leading)
                    
                    Button {
                        appUIState.presentedSheet = .addPerformance
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .padding(4)
                    }
                    .buttonStyle(.borderedProminent)
                    .clipShape(Circle())
                    .padding(.trailing)
                    .padding(.vertical)
                }
            }
        }
    }
    
}


private
extension PerformanceListView {
    
    /// Helper view: wraps the list and implements some actions on it.
    struct WrapperView: View {
        
        /// List of performances to show.
        let performances: [Performance]
        
        /// Which columns to render.
        let columns: PerformanceListView.Columns
        
        
        /// Measured maximum width of the date column to achieve a more table-like look.
        @State private
        var dateColumnWidth: CGFloat = 0
        
        @Environment(Repositories.self) private
        var repositories: Repositories
        
        @Environment(AppUIState.self) private
        var uiState: AppUIState
        
        @State private
        var alert: AlertFactory.Kind?
        
        
        var body: some View {
            GeometryReader {
                (geometry) in
                ScrollViewReader {
                    (proxy) in
                    
                    List(performances) {
                        (performance) in
                        
                        RowView(performance: performance, columns: columns, dateColumnWidth: dateColumnWidth)
                        .id(performance)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                delete(performance)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                edit(performance)
                            } label: {
                                Label("Edit", systemImage: "square.and.pencil")
                            }
                        }
                    }
                    .onPreferenceChange(MaxWidthPreferenceKey.self) {
                        dateColumnWidth = $0
                    }
                    .safeAreaInset(edge: .bottom) {
                        // Empty transparent inset
                        Color.clear
                            .frame(height: 80)
                    }
                    .alert(kind: $alert)
                    .onAppear {
                        // Start scrolled to bottom.
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: performances) {
                        // Content changed?
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: geometry.size) {
                        // Size changed, for example because the screen orientation changed?
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: geometry.safeAreaInsets) {
                        // Safe area insets changed, for example because the keyboard (dis)appeared?
                        DispatchQueue.main.async {
                            scrollToBottom(proxy: proxy)
                        }
                    }
                }
            }
        }
        
    }
    
}


private
extension PerformanceListView.WrapperView {
    
    /// Helper view: a row in the list.
    struct RowView: View {
        
        /// List of performances to show.
        let performance: Performance
        
        /// Which columns to render.
        let columns: PerformanceListView.Columns
        
        /// Maximum width of the date column to achieve a more table-like look.
        let dateColumnWidth: CGFloat
        
        
        @Environment(\.colorScheme) private
        var colorScheme: ColorScheme
        
        @ScaledMetric private
        var spacing: CGFloat = 15
        
        
        @ViewBuilder
        var body: some View {
            if columns == .all {
                // All columns visible: show the band name prominently, then venue and date below.
                VStack(alignment: .leading, spacing: 4) {
                    bandColumn(performance)
                    
                    HStack {
                        venueColum(performance)
                        
                        Spacer()
                        
                        dateColumn(performance)
                    }
                }
            } else {
                // Not all columns visible. Date should be first as that has more importance in this view mode.
                HStack(spacing: spacing) {
                    if columns.contains(.date) {
                        dateColumn(performance)
                            .reportMaxWidth()
                            .frame(width: dateColumnWidth, alignment: .trailing)
                    }
                    
                    if columns.contains(.band) {
                        bandColumn(performance)
                    }
                    
                    if columns.contains(.venue) {
                        venueColum(performance)
                    }
                }
            }
        }
        
        func bandColumn(_ performance: Performance) -> some View {
            Text(performance.band?.name ?? String(
                localized: "Unknown",
                comment: "Displayed when the band name is unknown"
            ))
            .font(columns == .all ? .headline : .body)
            .partialAttendance(performance.partialAttendance)
        }
        
        func venueColum(_ performance: Performance) -> some View {
            Text(performance.venue?.name ?? String(
                localized: "Unknown",
                comment: "Displayed when the venue name is unknown"
            ))
            .font(columns == .all ? .subheadline : .body)
            .foregroundStyle(columns == .all ? .secondary : .primary)
            .partialAttendance(performance.partialAttendance)
        }
        
        func dateColumn(_ performance: Performance) -> some View {
            Text(
                performance.date,
                format: .dateTime.year().month().day()
            )
            .font(columns == .all ? .subheadline : .body)
            .foregroundStyle(performance.date.yearColor(colorScheme: colorScheme))
            .partialAttendance(performance.partialAttendance, useOpacity: true)
        }
    }
    
    
    func delete(_ performance: Performance) {
        do {
            try repositories.delete(performance)
        } catch {
            alert = .deletePerformanceFailed(error)
        }
    }
    
    func edit(_ performance: Performance) {
        uiState.presentedSheet = .editPerformance(performance)
    }
    
    func scrollToBottom(proxy: ScrollViewProxy) {
        if let last = performances.last {
            // Scroll to bottom. The anchor point is "lower" than .bottom to absolutely scroll to the
            // bottom. With .bottom, there are a few pixels left to scroll.
            proxy.scrollTo(last, anchor: UnitPoint(x: 0.5, y: 1.5))
        }
    }
    
}

#endif
