//
//  SearchView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/12/21.
//

import SwiftUI

struct SearchView: View {
    @State private var text: String = ""
    @State private var isSearching = false
    @State private var scope: Scope = .video
    
    enum Scope: String, CaseIterable, CustomStringConvertible {
        case video = "Video"
        case user = "User"
        var description: String {
            return self.rawValue
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $text, placeholder: "Videos, Users", scopes: Scope.allCases) {
                    // onBegin:
                    withAnimation { isSearching = true }
                } onCancel: {
                    isSearching = false
                } onSearchClicked: {
                    
                } onScopeChange: { newScope in
                    scope = newScope
                }
                .padding(.horizontal, 6)
                
                if isSearching {
                    if text == "" {
                        // search recommendation
                        switch scope {
                        case .video:
                            // video search recommendations
                            ScrollView(showsIndicators: false) {
                                LazyVStack(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, pinnedViews: .sectionHeaders) {
                                    Section(header:
                                        HStack {
                                            Text("Suggested Searches")
                                                .font(.headline)
                                                .padding(.vertical, 4)
                                                .padding(.leading, 15)
                                            Spacer()
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            ZStack {
                                                Color.systemBackground
                                                Color.systemFill
                                            }
                                        )
                                    ) {
                                        // section content
                                        ForEach(0...10, id: \.self) { count in
                                            VStack {
                                                Button(action: { text = "Category \(count)" }) {
                                                    VStack {
                                                        Spacer()
                                                        HStack {
                                                            Text("Category \(count)")
                                                                .foregroundColor(.accentColor)
                                                            Spacer()
                                                        }
                                                        Spacer()
                                                    }
    //                                                .border(Color.red)
                                                }
                                                .frame(minHeight: 44)
                                                
                                                
                                                Divider()
                                            }
//                                            .padding(.top, count == 0 ? 4 : 0)
                                            
                                            
                                        }
                                        .padding(.leading, 24)

                                    }
                                    
                                    
                                    
                                }
                            }
                            .transition(.opacity)
                        case .user:
                            // user search recommendations
                            EmptyView()
                            
                        }
                        
                    } else {
                        // search result
                        Text("Search result")
                        
                    }
                    
                    // keep search bar at the top
                    Spacer()
                    
                } else {
                    // not searching - default view
                    Spacer()
                    
                    VStack {
                        Text("Default")
                    }
                    
                    Spacer()
                    
                }
                
            }
            .navigationTitle("Search")
            .navigationBarHidden(isSearching)
            
            
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var userData = UserData()
    static var previews: some View {
        MultiplePreview(embedInNavigationView: false) {
            SearchView()
        }
        .environmentObject(userData)
    }
}
