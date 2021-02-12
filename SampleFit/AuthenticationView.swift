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
                        .foregroundColor(userData.usernameInputStatus.color)
                    TextField("User name", text: $userData.username)
                        .textContentType(.username)
                        .font(.title3)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .overlay(
                    Group {
                        if userData.usernameInputStatus == .validating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        if userData.usernameInputStatus == .invalid {
                            Text("Not Available")
                                .font(Font.callout.bold())
                                .foregroundColor(userData.usernameInputStatus.color)
                        }
                    }
                    .padding(.trailing, 16)
                    
                , alignment: .trailing)
                // password field
                HStack(spacing: 12) {
                    Image(systemName: "lock.circle")
                        .font(Font.title)
                        .foregroundColor(userData.passwordInputStatus.color)
                    SecureField("Password", text: $userData.password)
                        .textContentType(.newPassword)
                        .font(.title3)
                }
                // repeat password field
                HStack(spacing: 12) {
                    Image(systemName: "lock.circle")
                        .font(Font.title)
                        .foregroundColor(userData.repeatPasswordInputStatus.color)
                    SecureField("Repeat password", text: $userData.repeatPassword)
                        .textContentType(.newPassword)
                        .font(.title3)
                }
                
                // create account button
                Button(action: {}) {
                    Text("Create Account")
                        .font(.headline)
                        .foregroundColor(Color(UIColor.systemBackground))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 7.5)
                                .fill(userData.userAuthenticationSignUpStatusDidValidate ? Color.green : Color.secondary)
                        )
                }
                .disabled(!userData.userAuthenticationSignUpStatusDidValidate)
                .padding(.top, 24)
            }
            .padding(.top, 60)

            
            Divider()
                .padding(.vertical, 8)
            
            
            // Sign up with Apple
            SignInWithAppleButton(.signUp, onRequest: { (request: ASAuthorizationAppleIDRequest) in
                request.requestedScopes = [.email, .fullName]
            }, onCompletion: { (result: Result<ASAuthorization, Error>) in
                userData.signUpwithAppleDidComplete(with: result)
            })
            .signInWithAppleButtonStyle(currentColorScheme == .dark ? .white : .black)
            .frame(height: 44)
            .id(currentColorScheme.hashValue)

            Spacer()
        }
        .onReceive(CurrentValueSubject<ColorScheme, Never>(colorScheme), perform: { newValue in
            self.currentColorScheme = newValue
        })
        .padding(.horizontal, 24)
        .navigationBarTitle("Sign Up")
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                AuthenticationView()
                    .environmentObject(UserData())
            }
            .previewDisplayName("Light mode")
            
            NavigationView {
                AuthenticationView()
                    .environmentObject(UserData())
            }
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark mode")
            
            NavigationView {
                AuthenticationView()
                    .environmentObject(UserData())
            }
            .previewDevice("iPhone 8")
            .previewDisplayName("iPhone 8")
        }
        
    }
}
