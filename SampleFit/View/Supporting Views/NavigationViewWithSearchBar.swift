//
//  NavigationViewWithSearchBar.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/19/21.
//

import SwiftUI
import Combine

/// Provides Search Bar functionality in a navigation view.
/// - Important: Keyboard event does not work correctly in Previews. Run this in simulator instead.
struct NavigationViewWithSearchBar<Content, TokenController>: UIViewControllerRepresentable where Content: View, TokenController: TokenEventController {
    @Binding var text: String
    let placeholder: String
    let scopes: [SearchScope]
    let tokenEventController: TokenController?
    let beginAction: () -> ()
    let cancellationAction: () -> ()
    let searchClickedAction: () -> ()
    let scopeChangeAction: (SearchScope) -> ()
    let tokenItemsChangeAction: ([Any?]) -> ()
    let content: () -> Content

    init(text: Binding<String>, placeholder: String, scopes: [SearchScope], tokenEventController: TokenController? = nil, @ViewBuilder content: @escaping () -> Content, onBegin: @escaping () -> () = {}, onCancel: @escaping () -> () = {}, onSearchClicked: @escaping () -> () = {}, onScopeChange: @escaping (_ newScope: SearchScope) -> () = { _ in }, onTokenItemsChange: @escaping ([Any?]) -> () = { _ in }) {
        self._text = text
        self.placeholder = placeholder
        self.scopes = scopes
        self.tokenEventController = tokenEventController
        self.content = content
        self.beginAction = onBegin
        self.cancellationAction = onCancel
        self.searchClickedAction = onSearchClicked
        self.scopeChangeAction = onScopeChange
        self.tokenItemsChangeAction = onTokenItemsChange
    }
    
    class Coordinator: NSObject, UISearchBarDelegate, UITextFieldDelegate {
        @Binding var text: String
        let contentHostingController: UIHostingController<Content>
        let searchController: UISearchController
        let scopes: [SearchScope]
        let tokenEventController: TokenController?
        let beginAction: () -> ()
        let cancellationAction: () -> ()
        let searchClickedAction: () -> ()
        let scopeChangeAction: (SearchScope) -> ()
        let tokenItemChangeAction: ([Any?]) -> ()
        var tokenWillChangeCancellable: AnyCancellable?
        
        init(text: Binding<String>, placeholder: String, scopes: [SearchScope], tokenEventController: TokenController?, onBegin: @escaping () -> (), onCancel: @escaping () -> (), onSearchClicked: @escaping () -> (), onScopeChange: @escaping (_ newScope: SearchScope) -> (), onTokenItemChange: @escaping ([Any?]) -> (), content: Content) {
            self._text = text
            self.scopes = scopes
            self.tokenEventController = tokenEventController
            self.beginAction = onBegin
            self.cancellationAction = onCancel
            self.searchClickedAction = onSearchClicked
            self.scopeChangeAction = onScopeChange
            self.tokenItemChangeAction = onTokenItemChange
            
            // configure the search bar
            self.contentHostingController = UIHostingController(rootView: content)
            self.searchController = UISearchController(searchResultsController: nil)
            searchController.searchBar.placeholder = placeholder
            searchController.searchBar.autocapitalizationType = .none
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.automaticallyShowsScopeBar = true
            searchController.searchBar.scopeButtonTitles = scopes.map { $0.description }
            contentHostingController.navigationItem.searchController = searchController
            contentHostingController.navigationItem.hidesSearchBarWhenScrolling = false
            searchController.searchBar.returnKeyType = .search
            
            // configure token capabilities
            searchController.searchBar.searchTextField.allowsDeletingTokens = true
        }
        
        // MARK: - Responding to user events
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
            scopeChangeAction(scopes[selectedScope])
        }
        func textFieldShouldClear(_ textField: UITextField) -> Bool {
            text = ""
            tokenItemChangeAction([])
            return true
        }
        
        
        fileprivate func addToken(_ token: UISearchToken) {
            var tokens = self.searchController.searchBar.searchTextField.tokens
            tokens.append(token)
            self.searchController.searchBar.searchTextField.tokens = tokens
            self.tokenItemChangeAction(tokens.map { $0.representedObject })
        }
        fileprivate func removeAllTokens() {
            self.searchController.searchBar.searchTextField.tokens.removeAll()
            self.tokenItemChangeAction(self.searchController.searchBar.searchTextField.tokens.map { $0.representedObject })
        }
        
        // MARK: - Editing Life cycle
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            // boost performance by freeing the main thread
            DispatchQueue.main.async {
                self.beginAction()
            }
        }
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            // boost performance by freeing the main thread
            DispatchQueue.main.async {
                self.cancellationAction()
            }
        }
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchClickedAction()
        }
        
        // MARK: - View update
        fileprivate func update(text: String, content: Content) {
            searchController.searchBar.text = text
            contentHostingController.rootView = content
            contentHostingController.view.setNeedsDisplay()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, placeholder: placeholder, scopes: scopes, tokenEventController: tokenEventController, onBegin: beginAction, onCancel: cancellationAction, onSearchClicked: searchClickedAction, onScopeChange: scopeChangeAction, onTokenItemChange: tokenItemsChangeAction, content: content())
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: context.coordinator.contentHostingController)
        navigationController.navigationBar.prefersLargeTitles = true
        
        // Setting delegates
        context.coordinator.searchController.searchBar.delegate = context.coordinator
        context.coordinator.searchController.searchBar.searchTextField.delegate = context.coordinator
        
        // setting up async callbacks
        context.coordinator.tokenWillChangeCancellable = tokenEventController?.tokenWillChangePublisher
            .sink { tokenChange in
                switch tokenChange {
                case let .addToken(token):
                    context.coordinator.addToken(token)
                case .removeAllTokens:
                    context.coordinator.removeAllTokens()
                }
            }
        
        // setting accessibility
        context.coordinator.searchController.searchBar.searchTextField.accessibilityIdentifier = .localIdentifier(for: .searchBarTextField)
        
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        context.coordinator.update(text: text, content: content())
    }
    
}

struct SearchNavigation_Preview: View {
    @State private var text: String = ""
    @State private var scope: SearchScope = .video
    @State private var isSearching = false
    var tokenController = SearchCategoryTokenEventController()
    var body: some View {
        
        NavigationViewWithSearchBar(text: $text, placeholder: "Placeholder", scopes: SearchScope.allCases, tokenEventController: tokenController) {
            if self.isSearching {
                if self.text.isEmpty {
                    switch scope {
                    case .video:
                        Text("Video Recommendations")
                    case .user:
                        Text("User Recommendations")
                    }
                } else {
                    switch scope {
                    case .video:
                        Text("Video Result")
                    case .user:
                        Text("User Result")
                    }
                }
            } else {
                Text("Default")
            }
        } onBegin: {
            self.isSearching = true
        } onCancel: {
            self.isSearching = false
        } onSearchClicked: {
            
        } onScopeChange: { (newScope) in
            scope = newScope
        }

        
    }
}

struct SearchNavigation_Previews: PreviewProvider {
    static var previews: some View {
        SearchNavigation_Preview()
    }
}
