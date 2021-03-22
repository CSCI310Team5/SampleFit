//
//  FollowingUserList.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/25/21.
//

import SwiftUI

struct FollowingUserList: View {
    @EnvironmentObject var userData: UserData
    @ObservedObject var privateInformation: PrivateInformation
    
    var body: some View {
        Group {
            if privateInformation.followedUsers.isEmpty {
                NoResults(title: "No Users", description: "You haven't followed anyone yet.")
            } else {
                List {
                    ForEach(privateInformation.followedUsers) { user in
                        NavigationLink(destination: UserDetail(user: user, privateInformation: privateInformation)) {
                            UserListDisplayItem(user: user)
                        }
                    }
                    .onDelete {
                        privateInformation.removeFollowedUser(at: $0)
                    }
                    .listRowInsets(.none)
                }
                .listStyle(PlainListStyle())
//                .toolbar {
//                    EditButton()
//                }
            }
        }
        .navigationBarTitle("Following", displayMode: .inline)
    }
}

struct FollowingUserList_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            FollowingUserList(privateInformation: PrivateInformation.examplePrivateInformation)
        }
    }
}
