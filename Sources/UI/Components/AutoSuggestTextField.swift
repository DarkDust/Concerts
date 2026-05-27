//
//  AutoSuggestTextField.swift
//  Concerts
//
//  Created by Marc Haisenko on 2026-05-27.
//


import SwiftUI

/// A text field with support for auto-suggestions.
///
/// On macOS, native APIs are used. On iOS, a custom popover is used.
struct AutoSuggestTextField<Suggestion: Identifiable>: View {
    
    /// Provides a list of suggestion items.
    typealias SuggestionProvider = (String) -> [Suggestion]
    
    /// Maps a suggestion item to a label text.
    typealias SuggestionLabel = (Suggestion) -> String
    
    /// Title of the text field.
    private
    let title: String
    
    /// Text of the text field.
    @Binding private
    var text: String
    
    /// Provides a list of suggestion items.
    private
    let suggestions: SuggestionProvider
    
    /// Maps a suggestion item to a label text.
    private
    let suggestionLabel: SuggestionLabel
    
    /// Current list of suggestions to present.
    @State private
    var currentSuggestions: [Suggestion] = []
    
    
    init(
        _ title: String,
        text: Binding<String>,
        suggestions: @escaping SuggestionProvider,
        suggestionLabel: @escaping SuggestionLabel
    ) {
        self.title = title
        self._text = text
        self.suggestions = suggestions
        self.suggestionLabel = suggestionLabel
    }
    
    var body: some View {
#if os(macOS)
        TextField(title, text: $text)
            .onChange(of: text) {
                (_, newValue) in
                
                let query = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard !query.isEmpty else {
                    currentSuggestions = []
                    return
                }
                
                currentSuggestions = suggestions(query)
            }
            .textInputSuggestions {
                ForEach(currentSuggestions) {
                    (suggestion) in
                    
                    let value = suggestionLabel(suggestion)
                    
                    Text(value)
                        .textInputCompletion(value)
                }
            }
#else
        VStack(alignment: .leading, spacing: 4) {
            TextField(title, text: $text)
            iosSuggestions
        }
        .task(id: text) {
            let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !query.isEmpty else {
                currentSuggestions = []
                return
            }
            
            try? await Task.sleep(for: .milliseconds(150))
            
            guard !Task.isCancelled else {
                return
            }
            
            currentSuggestions = suggestions(query)
        }
#endif
    }
    
    
#if os(iOS)
    @ViewBuilder private
    var iosSuggestions: some View {
        if !currentSuggestions.isEmpty {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(currentSuggestions) {
                        (suggestion) in
                        
                        let value = suggestionLabel(suggestion)
                        
                        Button {
                            text = value
                            currentSuggestions = []
                        } label: {
                            HStack {
                                Text(value)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        if suggestion.id != currentSuggestions.last?.id {
                            Divider()
                        }
                    }
                }
            }
            .frame(maxHeight: 150)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.quaternary)
            }
            .shadow(radius: 2)
        }
    }
#endif
    
}
