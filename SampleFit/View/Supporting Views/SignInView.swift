//
//  SignInView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI

import SwiftUI
import AuthenticationServices
import Combine

struct SignInView: View {
    @EnvironmentObject var userData: UserData
    @ObservedObject var signInInformation: UserData.SignInInformation
    @Environment(\.colorScheme) var colorScheme
    @State private var currentColorScheme: ColorScheme = .light
    
    var body: some View {
        VStack {
            
            // Custom sign in
            VStack(spacing: 16) {
                // username field
                HStack(spacing: 12) {
                    Image(systemName: "person.circle")
                        .font(.title)
                        .foregroundColor(signInInformation.usernameInputStatus.signInColor)
                    TextField("User name", text: $signInInformation.username)
                        .textContentType(.username)
                        .font(.title3)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }

                // password field
                HStack(spacing: 12) {
                    Image(systemName: "lock.circle")
                        .font(Font.title)
                        .foregroundColor(signInInformation.passwordInputStatus.signInColor)
                    SecureField("Password", text: $signInInformation.password)
                        .textContentType(.newPassword)
                        .font(.title3)
                }
                
                // sign in button
                Button(action: userData.signInUsingDefaultMethod) {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(Color(UIColor.systemBackground))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 7.5)
                                .fill(signInInformation.allowsSignIn ? signInInformation.passwordInputStatus.signInColor : Color.secondary)
                        )
                }
                .disabled(!signInInformation.allowsSignIn)
                .padding(.top, 24)
            }
            .padding(.top, 60)

            
            Divider()
                .padding(.vertical, 8)
            
            
            // Sign up with Apple
            SignInWithAppleButton(.signIn, onRequest: { (request: ASAuthorizationAppleIDRequest) in
                request.requestedScopes = [.fullName]
            }, onCompletion: { (result: Result<ASAuthorization, Error>) in
                userData.signInwithAppleDidComplete(with: result)
            })
            .signInWithAppleButtonStyle(currentColorScheme == .dark ? .white : .black)
            .frame(height: 44)
            .id(currentColorScheme.hashValue)

            Spacer()
        }
        // detects color scheme change and re-render
        .onReceive(CurrentValueSubject<ColorScheme, Never>(colorScheme), perform: { newValue in
            self.currentColorScheme = newValue
        })
        .padding(.horizontal, 24)
        .navigationBarTitle("Sign In")
    }
}

struct SignInView_Previews: PreviewProvider {
    static var userData = UserData()

    static var previews: some View {
        Group {
            NavigationView {
                SignInView(signInInformation: userData.signInInformation)
            }
            .previewDisplayName("Light mode")
            
            NavigationView {
                SignInView(signInInformation: userData.signInInformation)
            }
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark mode")
            
            NavigationView {
                SignInView(signInInformation: userData.signInInformation)
            }
            .previewDevice("iPhone 8")
            .previewDisplayName("iPhone 8")
        }
        .environmentObject(userData)
    }
}
