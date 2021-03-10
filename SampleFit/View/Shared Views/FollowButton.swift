//
//  FollowButton.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/23/21.
//

import SwiftUI

struct FollowButton: View {
    var following: Bool
    var action: () -> ()

    var body: some View {
        Button(action: action) {
            Group {
                if following {
                    Label("Followed", systemImage: "checkmark")
                        .foregroundColor(.green)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                } else {
                    Text("Follow")
                        .foregroundColor(.accentColor)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            Capsule(style: .circular)
                                .fill(Color.tertiarySystemFill)
                        )
                }
            }
            .font(Font.subheadline.weight(.bold))
            .textCase(.uppercase)
            .fixedSize(horizontal: true, vertical: false)
            .scaleEffect(0.85)
            .frame(minWidth: 44, minHeight: 44)
        }
    }
}

struct FollowButton_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            FollowButton(following: false, action: {})
        }
    }
}
