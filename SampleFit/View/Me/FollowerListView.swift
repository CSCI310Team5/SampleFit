//
//  FollowerListView.swift
//  SampleFit
//
//  Created by apple on 5/7/21.
//

import SwiftUI

struct FollowerListView: View {
    @EnvironmentObject var userData: UserData
    @ObservedObject var privateInformation: PrivateInformation
    
    var body: some View {
        Group {
            if privateInformation.followers.isEmpty {
                NoResults(title: "No Users", description: "You have no followers yet.")
            } else {
                List {
                    ForEach(privateInformation.followers) { user in
                        NavigationLink(destination: UserDetail(user: user, privateInformation: privateInformation)) {
                            UserListDisplayItem(user: user)
                        }
                    }
//                    .onDelete {
//                        privateInformation.removeFollowedUser(at: $0)
//                    }
                    .listRowInsets(.none)
                }
                .listStyle(PlainListStyle())

            }
        }
        .onAppear{
            privateInformation.getFollowers()
        }
        .navigationBarTitle("Followers", displayMode: .inline)
    }
}

struct FollowerListView_Previews: PreviewProvider {
    static var previews: some View {
        FollowerListView(privateInformation: PrivateInformation.examplePrivateInformation)
    }
}
