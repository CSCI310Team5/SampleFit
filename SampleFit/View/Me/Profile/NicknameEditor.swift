//
//  NicknameEditor.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/8/21.
//

import SwiftUI

struct NicknameEditor: View {
    @ObservedObject var draftProfile: PublicProfile
    var body: some View {
        HStack {
            // constant width container
            ZStack(alignment: .leading) {
                Text("Nickname")
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: UIScreen.main.bounds.width * 0.3)
            }
            Divider()
            
            TextField("", text: $draftProfile.nickname)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .frame(minHeight: 44)
                .multilineTextAlignment(.trailing)
                .background(    // custom placeholder
                    Group {
                        if !draftProfile.isNicknameSet || draftProfile.nickname.isEmpty {
                            NotSetView(isEditModeActive: true)
                        }
                    }
                    ,alignment: .trailing)
        }
        .padding(.horizontal)
        .frame(height: 44)
    }
}

struct NicknameEditor_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            NicknameEditor(draftProfile: PublicProfile.exampleProfile)
        }
    }
}
