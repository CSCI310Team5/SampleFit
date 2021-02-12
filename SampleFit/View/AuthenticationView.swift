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
                    SignUpView(signUpInformation: userData.signUpInformation)
                }
                if userData.signInStatus == .signedOut {
                    SignInView(signInInformation: userData.signInInformation)
                }
            }
            // controls navigation if user is signed in
            NavigationLink("Sign In", destination: HomeView()            .navigationBarBackButtonHidden(true)
                            .environmentObject(userData)
, isActive: $userData.shouldPresentMainView)
            .frame(width: 0, height: 0)
            
            
        }
        
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                AuthenticationView()
            }
            .previewDisplayName("Light mode")
            
            NavigationView {
                AuthenticationView()
            }
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark mode")
            
            NavigationView {
                AuthenticationView()
            }
            .previewDevice("iPhone 8")
            .previewDisplayName("iPhone 8")
        }
        .environmentObject(UserData())
    }
}
