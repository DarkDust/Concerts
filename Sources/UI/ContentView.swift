//
//  ContentView.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext)
    private var modelContext
    
    @Binding
    var showingAddPerformance: Bool
    
    
    var body: some View {
        NavigationStack {
            PerformanceListView()
                .toolbar {
                    ToolbarItem {
                        Button(action: addItem) {
                            Label("Add Item", systemImage: "plus")
                                .accessibilityIdentifier("add-item")
                        }
                    }
                }
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
extension ContentView {
    
    func addItem() {
        showingAddPerformance = true
    }
    
}


#Preview {
    ContentView(showingAddPerformance: .constant(false))
        .modelContainer(ModelContainer.mock(scenario: .basic))
}
