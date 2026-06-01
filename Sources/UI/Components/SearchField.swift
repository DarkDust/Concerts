//
//  SearchField.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-29.
//


import SwiftUI

// Haisenko 2026-06-01:
//
// On macOS, the binding is set on the outside and the view becomes the first responder. It immediately resets the
// `focus` binding to false.
// On iOS, it truly reflects the first responder state. Setting it to false resigns the first responder, for example.
//
// I tried to make the macOS binding behave the same way as on iOS, but it had strange side-effects with the table.
// The window's first responder was observed and the binding was updated as needed. Now, when the search field had the
// focus and I clicked into the table, the table selection briefly went to the new location, then jumped back and the
// table lost focus. I wasn't able to figure out why this happened and several attempts at working around it failed.
// It's not worth it spending any more time on this.

#if canImport(AppKit)
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

#elseif canImport(UIKit)
import UIKit

struct SearchField: UIViewRepresentable {
    
    /// The text to search.
    @Binding
    var searchText: String
    
    /// Binding that should be set to true when the search field should gain keyboard focus.
    @Binding
    var focus: Bool
    
    
    class Coordinator: NSObject, UISearchBarDelegate, UITextFieldDelegate {
        private
        var parent: SearchField
        
        init(_ parent: SearchField) {
            self.parent = parent
        }
        
        func searchBar(
            _ searchBar: UISearchBar,
            textDidChange searchText: String
        ) {
            parent.searchText = searchText
        }
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            if !parent.focus {
                parent.focus = true
            }
        }
        
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            if parent.focus {
                parent.focus = false
            }
        }
        
        func textFieldShouldClear(_ textField: UITextField) -> Bool {
            // Triggered when the "clear" (x) button is pressed.
            DispatchQueue.main.async {
                self.parent.focus = false
            }
            return true
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            parent.focus = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        searchBar.searchTextField.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = searchText
        
        if focus {
            if !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
            }
        } else {
            if uiView.isFirstResponder {
                uiView.resignFirstResponder()
            }
        }
    }
    
}
#endif
