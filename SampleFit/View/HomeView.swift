//
//  HomeView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userData: UserData
    @State private var selection: Tab = .me
    
    enum Tab: String {
        case workout = "Exercise"
        case browse = "Video & Live"
        case me = "Me"
        case search = "Search"
    }
    
    var body: some View {
        TabView(selection: $selection) {
            
            BrowseView(privateInformation: userData.privateInformation)
                .tabItem {
                    Label("Video & Live", systemImage: "play.fill")
                }
                .tag(Tab.browse)
            
            
            WorkoutBrowseView()
                .tabItem {
                    Label("Exercise", systemImage: "square.grid.2x2.fill")
                }
                .tag(Tab.workout)
            
            NavigationView {
                VStack {
                    MeView(privateInformation: userData.privateInformation)
                }
            }
                .tabItem {
                    Label("Me", systemImage: "person.fill")
                }
                .tag(Tab.me)
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(Tab.search)
        }
        .environmentObject(userData)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var userData = UserData.signedInUserData
    static var previews: some View {
        MultiplePreview(embedInNavigationView: false) {
            HomeView()
        }
        .environmentObject(userData)
    }
}
