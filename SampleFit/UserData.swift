//
//  UserData.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/10/21.
//

import Foundation
import Combine
import SwiftUI
import AuthenticationServices

/// Stores relavant information about the user
class UserData: ObservableObject {
    /// Indicates the input status of an entry of user information like username, password, etc.
    enum InputStatus {
        case notEntered
        case valid
        case invalid
        /// Color that represents the input status.
        var imageColor: Color {
            switch self {
            case .notEntered:
                return Color.primary
            case .valid:
                return Color.green
            case .invalid:
                return Color.red
            }
        }
    }

    @Published var username: String = "" {
        willSet {
            usernameWillSet(newValue)
        }
    }
    @Published var password: String = "" {
        willSet {
            passwordWillSet(newValue)
        }
    }
    @Published var repeatPassword: String = "" {
        willSet {
            repeatPasswordWillSet(newValue)
        }
    }
    
    @Published var usernameInputStatus: InputStatus = .notEntered
    @Published var passwordInputStatus: InputStatus = .notEntered
    @Published var repeatPasswordInputStatus: InputStatus = .notEntered
    @Published var userAuthenticationSignUpStatusDidValidate = false
    
    func usernameWillSet(_ newUsername: String) {
        if newUsername.count > 4 {
            usernameInputStatus = .valid
        } else {
            usernameInputStatus = .invalid
        }
        
        evaluateUserAuthenticationSignUpStatus()
    }
    
    func passwordWillSet(_ newPassword: String) {
        if !newPassword.isEmpty {
            passwordInputStatus = .valid
        } else {
            passwordInputStatus = .invalid
        }
        
        switch repeatPasswordInputStatus {
        case .notEntered:
            break
        default:
            repeatPasswordInputStatus = newPassword == repeatPassword ? .valid : .invalid
        }
        
        repeatPassword = ""
        repeatPasswordInputStatus = .notEntered
        
        evaluateUserAuthenticationSignUpStatus()
    }
        
    func repeatPasswordWillSet(_ newRepeatPassword: String) {
        if password == newRepeatPassword {
            repeatPasswordInputStatus = .valid
        } else {
            repeatPasswordInputStatus = .invalid
        }
        
        evaluateUserAuthenticationSignUpStatus()
    }
      
    /// Evaluates the authentication data status during sign up.
    func evaluateUserAuthenticationSignUpStatus() {
        userAuthenticationSignUpStatusDidValidate = usernameInputStatus == .valid
            && passwordInputStatus == .valid
            && repeatPasswordInputStatus == .valid
    }
    
    func signUpwithAppleDidComplete(with result: Result<ASAuthorization, Error>) {
        switch result {
        case let .success(authorization):
            switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                let userID = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email
                
                // TODO: Do something using the credential
                print(userID, fullName!, email!)

            case let passwordCredential as ASPasswordCredential:
                
                // TODO: Do something using the credential
                print(passwordCredential.user, passwordCredential.password)
                
            default:
                break
            }
            
            
        case let .failure(error):
            // TODO: Do something about the error
            print(error)
        }
    }
    
}
