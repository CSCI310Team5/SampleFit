//
//  UserListDisplayItem.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/20/21.
//

import SwiftUI

struct UserListDisplayItem: View {
    var user: PersonalInformation
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                if user.image != nil {
                    // FIXME: Incomplete
                } else {
                    // user image
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.secondary, lineWidth: 0.5)
                        )
                }
                
                // name label
                Text(user.identifier)
                    .fixedSize(horizontal: true, vertical: false)
                
                Spacer()
                
                // Placeholder to button to avoid complex text padding layout
                FollowButton()
                    .disabled(true)
                    .opacity(0.01)
                
            }
            .padding(.vertical, 8)
            
            Divider()
        }
        .padding(.horizontal, 20)

        .foregroundColor(.primary)
    }
}

struct UserListDisplayItem_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            UserListDisplayItem(user: PersonalInformation.examplePersonalInformation[0])
        }
    }
}
