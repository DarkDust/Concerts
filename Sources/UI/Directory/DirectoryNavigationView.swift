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
    
    /// All known bands.
    let bands: [Band]
    
    /// All known venues.
    let venues: [Venue]
    
    
    var body: some View {
        ScrollViewReader {
            (proxy) in
            
            List(selection: $selection) {
                switch kind {
                case .bands:
                    ForEach(bands) {
                        (band) in
                        
                        Text(band.name)
                            .tag(DirectoryView.Selection.band(band.id))
                    }
                    
                case .venues:
                    ForEach(venues) {
                        (venue) in
                        
                        Text(venue.name)
                            .tag(DirectoryView.Selection.venue(venue.id))
                    }
                }
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
    
    
    private
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
}
