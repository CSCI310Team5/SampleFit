//
//  HomeView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject var userData: UserData
    @State private var selection: Tab = .me
    @State private var workoutNotification: Bool = false
    
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
            
            
            WorkoutBrowseView(privateInformation: userData.privateInformation)
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
            
            SearchView(privateInformation: userData.privateInformation)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(Tab.search)
        }
        .environmentObject(userData)
        // fetch new exercise feeds when selection changed to browsing
        .onReceive(Just(selection), perform: { newSelection in
            if newSelection == .browse {
                userData.fetchExerciseFeeds()
                print("on Receive: fetching new exercise feedsd")
            }
        })
        
        .actionSheet(isPresented: $workoutNotification, content: {
       
            ActionSheet(title: Text("Your Workout Suggestion"), message: Text("The latest workout you did was \(userData.privateInformation.workoutHistory.last!.categories)\n You Could Continue Your Glory!"), buttons: [.default(Text("Dismiss"))])
        })
        
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                workoutNotification=userData.privateInformation.workoutHistory.count != 0
            }
        }
        
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
