//
//  HomeView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userData: UserData
    @State private var selection: Tab = .browse
    
    enum Tab: String {
        case browse = "Browse"
        case me = "Me"
        case search = "Search"
    }
    
    var body: some View {
        TabView(selection: $selection) {
            BrowseView(socialInformation: userData.socialInformation)
                .tabItem {
                    Label("Browse", systemImage: "list.and.film")
                }
                .tag(Tab.browse)
            
            NavigationView {
                VStack {
                    Text("Me")
                    Button("Sign out", action: userData.signOut)
                }
            }
                .tabItem {
                    Label("Me", systemImage: "person")
                }
                .tag(Tab.me)
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(Tab.search)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var userData = UserData()
    static var previews: some View {
        MultiplePreview(embedInNavigationView: false) {
            HomeView()
        }
        .environmentObject(userData)
    }
}
