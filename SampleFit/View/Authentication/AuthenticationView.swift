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
                if userData.signInStatus == .never || userData.signInStatus == .validatingFirstTime {
                    CreateAccountView(createAccountState: userData.createAccountAuthenticationState)
                }
                if userData.signInStatus == .signedOut || userData.signInStatus == .validating {
                    SignInView(signInAuthenticationState: userData.signInAuthenticationState)
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
