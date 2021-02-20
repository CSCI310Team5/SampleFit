//
//  ContentView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/10/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var userData = UserData.signedInUserData

    var body: some View {
        // showing either the authentication or the home view
        if userData.shouldPresentAuthenticationView {
            NavigationView {
                AuthenticationView()
                    .environmentObject(userData)
                    .accentColor(.systemBlue)
            }

        } else {
            HomeView()
                .environmentObject(userData)
                .transition(.opacity)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var userData = UserData()
    
    static var previews: some View {
        MultiplePreview(embedInNavigationView: false) {
            ContentView()
        }
        .environmentObject(userData)
    }
}
