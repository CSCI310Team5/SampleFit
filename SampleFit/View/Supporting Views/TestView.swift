//
//  TestView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI

struct TestView: View {
    @EnvironmentObject var userData: UserData
    var body: some View {
        VStack {
            Text("Home Page")
            NavigationLink("Next Page", destination: Text("Second Page"))
            Button("Sign out", action: userData.signOut)
        }
        
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
