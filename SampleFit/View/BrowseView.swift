//
//  BrowseView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI

struct BrowseView: View {
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        NavigationView {
            ExerciseList(socialInformation: userData.socialInformation)
        }
        
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var userData = UserData()
    static var previews: some View {
        MultiplePreview(embedInNavigationView: false) {
            BrowseView()
        }
        .environmentObject(userData)
    }
}


