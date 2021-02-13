//
//  SearchBar.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/12/21.
//

import SwiftUI

/// A search bar usable in SwiftUI.
struct SearchBar<Scope>: UIViewRepresentable where Scope: CustomStringConvertible {
    @Binding var text: String
    let placeholder: String
    let scopes: [Scope]
    let beginAction: () -> ()
    let cancellationAction: () -> ()
    let searchClickedAction: () -> ()
    let scopeChangeAction: (Scope) -> ()
    init(text: Binding<String>, placeholder: String, scopes: [Scope], onBegin: @escaping () -> () = {}, onCancel: @escaping () -> () = {}, onSearchClicked: @escaping () -> () = {}, onScopeChange: @escaping (_ newScope: Scope) -> () = { _ in }) {
        _text = text
        self.placeholder = placeholder
        self.scopes = scopes
        beginAction = onBegin
        cancellationAction = onCancel
        searchClickedAction = onSearchClicked
        scopeChangeAction = onScopeChange
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        let scopes: [Scope]
        let beginAction: () -> ()
        let cancellationAction: () -> ()
        let searchClickedAction: () -> ()
        let scopeChangeAction: (Scope) -> ()
        init(text: Binding<String>, scopes: [Scope], onBegin: @escaping () -> () = {}, onCancel: @escaping () -> () = {}, onSearchClicked: @escaping () -> () = {}, onScopeChange: @escaping (_ newScope: Scope) -> ()) {
            _text = text
            self.scopes = scopes
            beginAction = onBegin
            cancellationAction = onCancel
            searchClickedAction = onSearchClicked
            self.scopeChangeAction = onScopeChange
        }
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
            scopeChangeAction(scopes[selectedScope])
        }
        
        // MARK: - Editing Life cycle
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(true, animated: true)
            searchBar.setShowsScope(true, animated: false)
            beginAction()
        }
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            text = ""
            searchBar.setShowsScope(false, animated: false)
            searchBar.setShowsCancelButton(false, animated: true)
            searchBar.resignFirstResponder()
            cancellationAction()
        }
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchClickedAction()
        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text, scopes: scopes, onBegin: beginAction, onCancel: cancellationAction, onSearchClicked: searchClickedAction, onScopeChange: scopeChangeAction)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        searchBar.scopeButtonTitles = scopes.map { $0.description }
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}

struct SearchBar_Preview: View {
    @State private var text: String = ""
    var body: some View {
        VStack {
            SearchBar(text: $text, placeholder: "Search", scopes: ["Scope 1", "Scope 2", "Scope 3"])
            Spacer()
        }
    }
}
struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar_Preview()
    }
}
