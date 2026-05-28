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
            PerformanceListView()
                .tabItem {
                    Label(
                        LocalizedStringResource("Performances", comment: "Tab view title: list of performances"),
                        systemImage: "music.note.list"
                    )
                }
                .toolbar {
                    ToolbarItem {
                        Button(action: addItem) {
                            Label(
                                LocalizedStringResource(
                                    "Add Performance",
                                    comment: "Toolbar button title: add a performance"
                                ),
                                systemImage: "plus"
                            )
                            .accessibilityIdentifier("add-item")
                        }
                    }
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
                AddPerformanceView()
                    .frame(minWidth: 400, minHeight: 100)
                    .presentationDetents([.medium])
            }
        }
    }
    
}


private
extension MainView {
    
    func addItem() {
        uiState.presentedSheet = .addPerformance
    }
    
}


#Preview {
    MainView()
        .modelContainer(ModelContainer.mock(scenario: .basic))
        .environment(AppUIState())
}
