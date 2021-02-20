//
//  UserDetail.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/20/21.
//

import SwiftUI

struct UserDetail: View {
    var user: PersonalInformation
    var body: some View {
        VStack {
            Text("User Detail View")
            Text(user.identifier)
        }
    }
}

struct UserDetail_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            UserDetail(user: PersonalInformation.examplePersonalInformation[0])
        }
    }
}
