//
//  AuthenticationView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/10/21.
//

import SwiftUI
import AuthenticationServices
import Combine


struct AuthenticationView: View {
    @EnvironmentObject var userData: UserData
    var body: some View {
        VStack {
            // either sign in view or sign up view
            Group {
                if userData.signInStatus == .never {
                    CreateAccountView(createAccountInformation: userData.createAccountInformation)
                }
                if userData.signInStatus == .signedOut {
                    SignInView(signInInformation: userData.signInInformation)
                }
            }
            
        }
        
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        MultiplePreview(embedInNavigationView: true) {
            AuthenticationView()
        }
        .environmentObject(UserData())
    }
}
