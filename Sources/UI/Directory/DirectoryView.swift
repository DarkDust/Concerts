//
//  DirectoryView.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-29.
//

import Foundation
import SwiftUI
import SwiftData


/// View showing which bands played at which venues, and vice versa.
struct DirectoryView: View {
    // A few notes about the layout, selection, and scrolling:
    //
    // On macOS and iPad, the layout should use a split view with the toggle which data to use in the navigation view.
    // When switching between bands and venues, the scroll position gets lost. So the selected item is remembered and
    // is scrolled to when view list (re)appears.
    //
    // This doesn't work well on iPhone. Remembering the selection causes the last detail view to be visible after the
    // switch. Workaround is to use a tab view and have distinct navigation split views with just one list view on each
    // tab, which does preserve the scroll position.
    
    /// Which kind of data to show in the navigation.
    enum Kind {
        case bands
        case venues
    }
    
    /// Helper to unambigiously identify bands and venues.
    enum Selection: Hashable, Identifiable {
        case band(Band.ID)
        case venue(Venue.ID)
        
        var id: PersistentIdentifier {
            switch self {
            case .band(let id): return id
            case .venue(let id): return id
            }
        }
    }
    
    /// Which kind of data to show in the navigation.
    @State private
    var kind: Kind = .bands
    
    /// Horizontal size class to decide which layout to use.
    @Environment(\.horizontalSizeClass) private
    var horizontalSizeClass
    
    /// Currently selected band.
    @State private
    var bandSelection: Selection?
    
    /// Currently selected venue.
    @State private
    var venueSelection: Selection?
    
    /// Currently selected band or venue, depending on the current ``kind`` for the macOS and iPad UI.
    private
    func combinedSelectionBinding() -> Binding<Selection?> {
        Binding(
            get: {
                switch kind {
                case .bands:
                    return bandSelection
                    
                case .venues:
                    return venueSelection
                }
            },
            set: {
                switch $0 {
                case .none:
                    break
                case .some(.band):
                    bandSelection = $0
                case .some(.venue):
                    venueSelection = $0
                }
            }
        )
    }
    
    @Query(sort: [
        SortDescriptor(\Band.name, order: .forward),
    ])
    var bands: [Band]
    
    @Query(sort: [
        SortDescriptor(\Venue.name, order: .forward),
    ])
    var venues: [Venue]
    
    
    var body: some View {
#if os(iOS)
        if horizontalSizeClass == .compact {
            narrowLayout
        } else {
            wideLayout
        }
#else
        wideLayout
#endif
    }
    
    
#if os(iOS)
    @ViewBuilder private
    var narrowLayout: some View {
        // A large amount of testing and cursing went into getting rid of ugly jumps when navigating to a detail view.
        // Basically, we need to force showing the navigation bar in the collapsed state as well. If we don't want any
        // title to be visible, this can do the trick:
        //
        // ToolbarItem(placement: .principal) {
        //     Color.clear
        //         .frame(width: 1, height: 1)
        // }
        //
        // I've opted to show a symbol instead, it's a bit nicer.
        //
        // In any case, `.toolbarTitleDisplayMode(.inline)` on both navigation and detail view is required as well.
        //
        // But the problems don't stop here: the navigation list style must explicitly be `plain`, otherwise we get an
        // empty space between the list content and navigation bar. Probably an empty list section header.
        
        VStack(spacing: 0) {
            TabView(selection: $kind) {
                NavigationSplitView {
                    DirectoryNavigationView(
                        mode: .single,
                        kind: .constant(.bands),
                        selection: $bandSelection,
                        bands: bands,
                        venues: venues
                    )
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Image(systemName: "music.microphone")
                        }
                    }
                    .toolbarTitleDisplayMode(.inline)

                } detail: {
                    if let band = selectedBand {
                        DirectoryDetailView(value: .band(band))
                    } else {
                        Text("Nothing selected")
                    }
                }
                .tag(Kind.bands)
                
                NavigationSplitView {
                    DirectoryNavigationView(
                        mode: .single,
                        kind: .constant(.venues),
                        selection: $venueSelection,
                        bands: bands,
                        venues: venues
                    )
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Image(systemName: "mappin.and.ellipse")
                        }
                    }
                    .toolbarTitleDisplayMode(.inline)

                } detail: {
                    if let venue = selectedVenue {
                        DirectoryDetailView(value: .venue(venue))
                    } else {
                        Text("Nothing selected")
                    }
                }
                .tag(Kind.venues)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            Divider()
            
            kindPicker
                .padding()
        }
    }
#endif
    
    
    @ViewBuilder private
    var wideLayout: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                kindPicker
                
                Divider()
                    .padding(.top)
                
                DirectoryNavigationView(
                    mode: .combined,
                    kind: $kind,
                    selection: combinedSelectionBinding(),
                    bands: bands,
                    venues: venues
                )
                .frame(minWidth: 300)
            }
        } detail: {
            switch kind {
            case .bands:
                if let band = selectedBand {
                    DirectoryDetailView(value: .band(band))
                } else {
                    Text("Nothing selected")
                }
                
            case .venues:
                if let venue = selectedVenue {
                    DirectoryDetailView(value: .venue(venue))
                } else {
                    Text("Nothing selected")
                }
            }
        }
    }
    
}

private
extension DirectoryView {
    
    var kindPicker: some View {
        Picker(
            LocalizedStringResource(
                "Type",
                comment: "Picker label for the directory data selection. Should not be visible."
            ),
            selection: $kind
        ) {
            Text(
                LocalizedStringResource("Bands", comment: "Picker text for the bands directory data selection.")
            )
            .tag(Kind.bands)
            
            Text(
                LocalizedStringResource("Venues", comment: "Picker text for the venues directory data selection.")
            )
            .tag(Kind.venues)
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }
    
    
    var selectedBand: Band? {
        if case .band(let id) = bandSelection {
            return bands.first(where: { $0.id == id })
        }
        return nil
    }
    
    
    var selectedVenue: Venue? {
        if case .venue(let id) = venueSelection {
            return venues.first(where: { $0.id == id })
        }
        return nil
    }
    
}
