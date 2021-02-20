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
                
                
                Text(user.identifier)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 20)

            Divider()
                .padding(.leading, 85)
        }
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
