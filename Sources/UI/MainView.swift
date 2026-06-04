//
//  MainView.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-26.
//

import SwiftUI
import SwiftData

/// The main app view providing the outer navigation.
struct MainView: View {
    
    /// Shared UI state.
    @Environment(AppUIState.self)
    private var uiState: AppUIState
    
    
    var body: some View {
        @Bindable var uiState = uiState
        
        TabView {
            PerformanceListMainView()
                .tabItem {
                    Label(
                        LocalizedStringResource("Performances", comment: "Tab view title: list of performances"),
                        systemImage: "music.note.list"
                    )
                }
            
            DirectoryView()
                .tabItem {
                    Label(
                        LocalizedStringResource("Directory", comment: "Tab view title: view bands and venues"),
                        systemImage: "music.note.house"
                    )
                }
            
            StatisticsView()
                .tabItem {
                    Label(
                        LocalizedStringResource("Statistics", comment: "Tab view title: statistics"),
                        systemImage: "chart.bar"
                    )
                }
            
            // On macOS, this is a `Settings` scene in `ConcertsApp`.
            #if os(iOS)
            SettingsView()
                .tabItem {
                    Label(
                        LocalizedStringResource("Settings", comment: "Tab view title: settings"),
                        systemImage: "gearshape"
                    )
                }
            #endif
        }
        .sheet(item: $uiState.presentedSheet) {
            (sheet) in
            
            switch sheet {
            case .addPerformance:
                AddOrEditPerformanceView(existing: nil)
                    .frame(minWidth: 400, minHeight: 100)
                    .presentationDetents([.medium])
                
            case .editPerformance(let performance):
                AddOrEditPerformanceView(existing: performance)
                    .frame(minWidth: 400, minHeight: 100)
                    .presentationDetents([.medium])
            }
        }
    }
    
}


#Preview {
    MainView()
        .modelContainer(ModelContainer.mock(scenario: .basic))
        .environment(AppUIState())
}
