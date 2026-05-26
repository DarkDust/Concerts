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
    
    
    var body: some View {
        NavigationSplitView {
            List {
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                            .accessibilityIdentifier("add-item")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }
    
}


private
extension ContentView {
    
    func addItem() {
        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
        }
    }

    func deleteItems(offsets: IndexSet) {
        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
        }
    }
}


#Preview {
    ContentView()
        .modelContainer(ModelContainer.mock())
}
