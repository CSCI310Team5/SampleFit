//
//  CreateAccountView.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import SwiftUI
import AuthenticationServices
import Combine

struct CreateAccountView: View {
    @EnvironmentObject var userData: UserData
    @ObservedObject var createAccountInformation: CreateAccountInformation
    @Environment(\.colorScheme) var colorScheme
    @State private var currentColorScheme: ColorScheme = .light
    
    var body: some View {
        VStack {
            
            // Custom sign in
            VStack(spacing: 8) {
                // username field
                UsernameTextField($createAccountInformation.username, inputStatus: createAccountInformation.usernameInputStatus, colorType: \.signUpColor)
                // password field
                CreateAccountPasswordTextField($createAccountInformation.password, inputStatus: createAccountInformation.passwordInputStatus)
                // repeat password field
                CreateAccountRepeatPasswordTextField($createAccountInformation.repeatPassword, inputStatus: createAccountInformation.repeatPasswordInputStatus)
                
                // create account button
                Button(action: userData.createAccountUsingDefaultMethod) {
                    Group {
                        if userData.signInStatus != .validatingFirstTime {
                            Text("Create Account")
                        } else {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding(.vertical)
                        }
                    }
                    .font(.headline)
                    .foregroundColor(Color(UIColor.systemBackground))
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 7.5)
                            .fill(createAccountInformation.allowsSignUp ? createAccountInformation.passwordInputStatus.signUpColor : Color.secondary)
                    )
                }
                .disabled(!createAccountInformation.allowsSignUp || userData.signInStatus == .validatingFirstTime)
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
            .disabled(!createAccountInformation.allowsSignUp || userData.signInStatus == .validating)

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
        MultiplePreview(embedInNavigationView: true) {
            CreateAccountView(createAccountInformation: userData.createAccountInformation)

        }
        .environmentObject(userData)
        
    }
}
