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
        
        @Binding
        var searchText: String
        
        @Environment(AppUIState.self) private
        var appUIState: AppUIState
        
        @State private
        var searchFocused: Bool = false
        
        
        var body: some View {
            ZStack(alignment: .bottom) {
                ListView(performances: performances)
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
    
    /// Helper view: the actual iOS list view implementation.
    struct ListView: View {
        
        let performances: [Performance]
        
        @Environment(Repositories.self) private
        var repositories: Repositories
        
        @Environment(\.colorScheme) private
        var colorScheme: ColorScheme
        
        @State private
        var alert: AlertFactory.Kind?
        
        
        var body: some View {
            GeometryReader {
                (geometry) in
                ScrollViewReader {
                    (proxy) in
                    
                    List(performances) {
                        (performance) in
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(performance.band?.name ?? String(
                                localized: "Unknown",
                                comment: "Displayed when the band name is unknown"
                            ))
                            .font(.headline)
                            .partialAttendance(performance.partialAttendance)
                            
                            HStack {
                                Text(performance.venue?.name ?? String(
                                    localized: "Unknown",
                                    comment: "Displayed when the venue name is unknown"
                                ))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .partialAttendance(performance.partialAttendance)
                                
                                Spacer()
                                
                                Text(
                                    performance.date,
                                    format: .dateTime.year().month().day()
                                )
                                .font(.subheadline)
                                .foregroundStyle(performance.date.yearColor(colorScheme: colorScheme))
                                .partialAttendance(performance.partialAttendance, useOpacity: true)
                            }
                        }
                        .id(performance)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                delete(performance)
                            } label: {
                                Label("Delete", systemImage: "trash")
                                // Button label to delete the performance
                            }
                        }
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
        
        
        private
        func delete(_ performance: Performance) {
            do {
                try repositories.delete(performance)
            } catch {
                alert = .deletePerformanceFailed(error)
            }
        }
        
        private
        func scrollToBottom(proxy: ScrollViewProxy) {
            if let last = performances.last {
                // Scroll to bottom. The anchor point is "lower" than .bottom to absolutely scroll to the
                // bottom. With .bottom, there are a few pixels left to scroll.
                proxy.scrollTo(last, anchor: UnitPoint(x: 0.5, y: 1.5))
            }
        }
    }
    
}

#endif
