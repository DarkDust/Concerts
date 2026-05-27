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
    
    /// SwiftData model context.
    @Environment(\.modelContext)
    private var modelContext
    
    /// Boolean to toggle the ``AddPerformanceView`` sheet.
    @Binding
    var showingAddPerformance: Bool
    
    
    var body: some View {
        TabView {
            PerformanceListView()
                .tabItem {
                    Label("Performances", systemImage: "music.note.list")
                }
                .toolbar {
                    ToolbarItem {
                        Button(action: addItem) {
                            Label("Add Item", systemImage: "plus")
                                .accessibilityIdentifier("add-item")
                        }
                    }
                }
            
            StatisticsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar")
                }
            
            // On macOS, this is a `Settings` scene in `ConcertsApp`.
            #if os(iOS)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
            #endif
        }
        .environment(Repositories(context: modelContext))
        .sheet(isPresented: $showingAddPerformance) {
            AddPerformanceView()
                .environment(Repositories(context: modelContext))
                .frame(minWidth: 400, minHeight: 100)
                .presentationDetents([.medium])
        }
    }
    
}


private
extension MainView {
    
    func addItem() {
        showingAddPerformance = true
    }
    
}


#Preview {
    MainView(showingAddPerformance: .constant(false))
        .modelContainer(ModelContainer.mock(scenario: .basic))
}
