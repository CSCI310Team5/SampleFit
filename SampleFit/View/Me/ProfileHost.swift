//
//  ProfileHost.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/7/21.
//

import SwiftUI

struct ProfileHost: View {
    @ObservedObject var publicProfile: PublicProfile
    @Environment(\.editMode) private var editMode
    
    init(publicProfile: PublicProfile) {
        self.publicProfile = publicProfile
    }
    
    var body: some View {
        ScrollView {
            if editMode?.wrappedValue == .inactive {
                DetailedProfileSummary(publicProfile: publicProfile)
            } else {
                ProfileEditor(publicProfile: publicProfile)
            }
        }
        .padding(.top, 50)

        .toolbar {
            EditButton()
        }
        .navigationBarTitle("Profile Details", displayMode: .inline)
    }
}


struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            ProfileHost(publicProfile: PublicProfile.exampleProfile)
        }
    }
}
