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
        NavigationView {
            AuthenticationView()
                .environmentObject(userData)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
                .environmentObject(UserData())
        }
    }
}
