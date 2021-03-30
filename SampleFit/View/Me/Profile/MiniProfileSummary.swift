//
//  MiniProfileSummary.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/7/21.
//

import SwiftUI

struct MiniProfileSummary: View {
    @ObservedObject var publicProfile: PublicProfile
    var body: some View {
        Section {
            HStack {
                Spacer()
                VStack(spacing: 16) {
                    
                    CircleImage(image: publicProfile.image).accessibility(localIdentifier: .profileAvatar)
                    
                    // top portion
                    VStack {
                        // nickname
                        if let nickName = publicProfile.nickname {
                            Text(nickName)
                                .bold()
                                .font(.title)
                                .lineLimit(1)
                        } else {
                            Text(publicProfile.identifier)
                                .bold()
                                .font(.title)
                                .lineLimit(1)
                        }
                        
                        // identifier
                        Text(publicProfile.identifier)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color(UIColor.systemGroupedBackground))
        
    }
}

struct MiniProfileSummary_Previews: PreviewProvider {
    static var previews: some View {
        MiniProfileSummary(publicProfile: PublicProfile.exampleProfile)
    }
}
