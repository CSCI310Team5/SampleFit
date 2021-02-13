//
//  ContentView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/10/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var userData = UserData()

    var body: some View {
        HomeView()
            .environmentObject(userData)
            .accentColor(.systemBlue)
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
