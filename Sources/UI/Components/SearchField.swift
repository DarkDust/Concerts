//
//  SearchField.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-29.
//


#if os(macOS)
import SwiftUI
import AppKit


/// Wrap a ``NSSearchField`` and support requesting focus for it, even when placed in a toolbar.
///
/// Using `.searchable(…)` on a `Table` puts a search field above the table, but not in the toolbar.
/// The `.focused(…)` modifier of SwiftUI does not seem to work when a text field is placed in a toolbar.
///
/// So this wrapper gives a native, full features search field that can be placed in the toolbar and is able to gain
/// focus.
///
/// Yet another hack around SwiftUI being incomplete and buggy.
struct SearchField: NSViewRepresentable {
    
    /// The text to search.
    @Binding
    var searchText: String
    
    /// Binding that should be set to true when the search field should gain keyboard focus.
    @Binding
    var focus: Bool
    
    
    class Coordinator: NSObject, NSSearchFieldDelegate {
        private
        var parent: SearchField
        
        init(_ parent: SearchField) {
            self.parent = parent
        }
        
        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSSearchField else { return }
            parent.searchText = field.stringValue
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSSearchField {
        let field = NSSearchField()
        field.delegate = context.coordinator
        return field
    }
    
    func updateNSView(_ nsView: NSSearchField, context: Context) {
        nsView.stringValue = searchText
        
        if focus, nsView.window?.firstResponder != nsView.currentEditor() {
            DispatchQueue.main.async {
                nsView.window?.makeFirstResponder(nsView)
                focus = false
            }
        }
    }
    
}

#endif
