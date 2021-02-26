//
//  MeView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/25/21.
//

import SwiftUI

struct MeView: View {
    @ObservedObject var privateInformation: PrivateInformation
    var body: some View {
        List {
            
            Section {
                NavigationLink(destination: FavoriteExercisesList(privateInformation: privateInformation)) {
                    Label {
                        Text("Favorites")
                    } icon: {
                        Image(systemName: "star.fill")
                    }
                }
                
                NavigationLink(destination: FollowingUserList(privateInformation: privateInformation)) {
                    Label {
                        Text("Following")
                    } icon: {
                        Image(systemName: "person.fill")
                    }
                }
                
                
                
            }
            
            
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Me")
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            MeView(privateInformation: PrivateInformation.examplePrivateInformation)
        }
        .environmentObject(PrivateInformation.examplePrivateInformation)
        
    }
}
