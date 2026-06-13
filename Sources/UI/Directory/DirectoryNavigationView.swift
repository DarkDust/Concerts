//
//  DirectoryNavigationView.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-29.
//

import Foundation
import SwiftUI
import SwiftData


/// Navigation view for the directory view.
struct DirectoryNavigationView: View {
    
    /// How this view should behave.
    enum Mode {
        /// The view is only showing one data type. Used on iPhone.
        case single
        
        /// The data (``kind``) can change at runtime. Used on macOS and iPad.
        case combined
    }
    
    /// How this view should behave.
    let mode: Mode
    
    /// Currently selected data kind.
    @Binding
    var kind: DirectoryView.Kind
    
    /// Current list selection.
    @Binding
    var selection: DirectoryView.Selection?
    
    @Binding
    var searchText: String
    
#if os(iOS)
    @State private
    var searchFocused: Bool = false
#endif
    
    /// All known bands.
    let bands: [Band]
    
    /// All known venues.
    let venues: [Venue]
    
    @Environment(\.horizontalSizeClass) private
    var horizontalSizeClass
    
    
    var body: some View {
        ScrollViewReader {
            (proxy) in
            
            listWrapperView
                .conditional(horizontalSizeClass == .compact) {
                    // See large comment in DirectoryView.swift, narrowLayout.
                    $0.listStyle(.plain)
                }
                .onAppear {
                    if mode == .combined {
                        scrollToSelection(proxy: proxy)
                    }
                }
                .onChange(of: kind) {
                    scrollToSelection(proxy: proxy)
                }
        }
    }
}
    
    
private
extension DirectoryNavigationView {
    
    @ViewBuilder
    var listWrapperView: some View {
#if os(macOS)
        listView
#else
        ZStack(alignment: .bottom) {
            listView
                .safeAreaInset(edge: .bottom) {
                    // Empty transparent inset
                    Color.clear
                        .frame(height: 80)
                }
                .onChange(of: selection) {
                    searchFocused = false
                }
            
            HStack {
                SearchField(searchText: $searchText, focus: $searchFocused)
                    .padding(.leading)
            }
        }
#endif
    }
    
    
    @ViewBuilder
    var listView: some View {
        List(selection: $selection) {
            switch kind {
            case .bands:
                ForEach(filteredBands) {
                    (band) in
                    
                    Text(band.name)
                        .tag(DirectoryView.Selection.band(band.id))
                }
                
            case .venues:
                ForEach(filteredVenues) {
                    (venue) in
                    
                    Text(venue.name)
                        .tag(DirectoryView.Selection.venue(venue.id))
                }
            }
        }
    }
    
    func scrollToSelection(proxy: ScrollViewProxy) {
        if let selection {
            proxy.scrollTo(selection, anchor: .center)
            return
        }
        
        switch kind {
        case .bands:
            if let first = bands.first?.id {
                proxy.scrollTo(DirectoryView.Selection.band(first), anchor: .top)
            }
            
        case .venues:
            if let first = venues.first?.id {
                proxy.scrollTo(DirectoryView.Selection.venue(first), anchor: .top)
            }
        }
    }
    
    var filteredBands: [Band] {
        if searchText.isEmpty {
            return bands
        }
        
        return bands.filter {
            $0.name.localizedStandardContains(searchText)
        }
    }
    
    var filteredVenues: [Venue] {
        if searchText.isEmpty {
            return venues
        }
        
        return venues.filter {
            $0.name.localizedStandardContains(searchText)
        }
    }
    
}
