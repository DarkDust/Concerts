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
    
}


private
extension PerformanceListView {
    
    /// Helper view: the actual iOS list view implementation.
    struct ListView: View {
        
        let performances: [Performance]
        
        @Environment(Repositories.self) private
        var repositories: Repositories
        
        @State private
        var alert: AlertFactory.Kind?
        
        
        var body: some View {
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
                            .foregroundStyle(.secondary)
                            .partialAttendance(performance.partialAttendance)
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
                    if let last = performances.last {
                        // Scroll to bottom. The anchor point is "lower" than .bottom to absolutely scroll to the
                        // bottom. With .bottom, there are a few pixels left to scroll.
                        proxy.scrollTo(last, anchor: UnitPoint(x: 0.5, y: 1.5))
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
    }
    
}

#endif
