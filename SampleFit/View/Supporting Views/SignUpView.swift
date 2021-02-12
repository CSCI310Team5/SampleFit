//
//  SignUpView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI
import AuthenticationServices
import Combine

struct SignUpView: View {
    @EnvironmentObject var userData: UserData
    @ObservedObject var signUpInformation: UserData.SignUpInformation
    @Environment(\.colorScheme) var colorScheme
    @State private var currentColorScheme: ColorScheme = .light
    
    var body: some View {
        VStack {
            
            // Custom sign in
            VStack(spacing: 8) {
                // username field
                HStack(spacing: 12) {
                    Image(systemName: "person.circle")
                        .font(.title)
                        .foregroundColor(signUpInformation.usernameInputStatus.signUpColor)
                    TextField("User name", text: $signUpInformation.username)
                        .textContentType(.username)
                        .font(.title3)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .frame(minHeight: 44)
                }
                .overlay(
                    Group {
                        if signUpInformation.usernameInputStatus == .validating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        if signUpInformation.usernameInputStatus == .invalid {
                            Text("Not Available")
                                .font(Font.callout.bold())
                                .foregroundColor(signUpInformation.usernameInputStatus.signUpColor)
                        }
                    }
                    .padding(.trailing, 16)
                    
                , alignment: .trailing)
                // password field
                HStack(spacing: 12) {
                    Image(systemName: "lock.circle")
                        .font(Font.title)
                        .foregroundColor(signUpInformation.passwordInputStatus.signUpColor)
                    SecureField("Password", text: $signUpInformation.password)
                        .textContentType(.newPassword)
                        .font(.title3)
                        .frame(minHeight: 44)
                }
                // repeat password field
                HStack(spacing: 12) {
                    Image(systemName: "lock.circle")
                        .font(Font.title)
                        .foregroundColor(signUpInformation.repeatPasswordInputStatus.signUpColor)
                    SecureField("Repeat password", text: $signUpInformation.repeatPassword)
                        .textContentType(.newPassword)
                        .font(.title3)
                        .frame(minHeight: 44)
                }
                
                // create account button
                Button(action: userData.signUpUsingDefaultMethod) {
                    Text("Create Account")
                        .font(.headline)
                        .foregroundColor(Color(UIColor.systemBackground))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 7.5)
                                .fill(signUpInformation.allowsSignUp ? signUpInformation.passwordInputStatus.signUpColor : Color.secondary)
                        )
                }
                .disabled(!signUpInformation.allowsSignUp)
                .padding(.top, 24)
            }
            .padding(.top, 60)

            
            Divider()
                .padding(.vertical, 8)
            
            
            // Sign up with Apple
            SignInWithAppleButton(.signUp, onRequest: { (request: ASAuthorizationAppleIDRequest) in
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
        .navigationBarTitle("Sign Up")
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var userData = UserData()
    static var previews: some View {
        Group {
            NavigationView {
                SignUpView(signUpInformation: userData.signUpInformation)
            }
            .previewDisplayName("Light mode")
            
            NavigationView {
                SignUpView(signUpInformation: userData.signUpInformation)
            }
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark mode")
            
            NavigationView {
                SignUpView(signUpInformation: userData.signUpInformation)
            }
            .previewDevice("iPhone 8")
            .previewDisplayName("iPhone 8")
        }
        .environmentObject(userData)
        
    }
}
