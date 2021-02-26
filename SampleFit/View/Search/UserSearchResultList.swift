//
//  UserSearchResultList.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/25/21.
//

import SwiftUI

struct UserSearchResultList: View {
    var users: [PublicProfile]
    @ObservedObject var privateInformation: PrivateInformation
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(users) { user in
                    ZStack(alignment: .trailing) {
                        NavigationLink(destination: UserDetail(user: user)) {
                            VStack {
                                UserListDisplayItem(user: user)
                                    .padding(.top, user == users[0] ? 4 : 0)
                                Divider()
                            }
                        }
                        
                        FollowButton(following: privateInformation.hasFollowed(user), action: { privateInformation.toggleUserInFollowed(user) })
                    }
                    .padding(.horizontal, 20)
                    
                }
            }
            
        }
    }
}


struct UserList_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            UserSearchResultList(users: PublicProfile.exampleProfiles, privateInformation: PrivateInformation.examplePrivateInformation)
        }
    }
}
