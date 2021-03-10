//
//  SignInInformation.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/17/21.
//

import Foundation
import Combine

/// Stores information during sign in.
class SignInInformation: ObservableObject {
    @Published var username: String = "" {
        willSet {
            validateUsername(newValue)
        }
    }
    @Published var password: String = "" {
        willSet {
            validatePassword(newValue)
        }
    }
    
    @Published var usernameInputStatus: InputStatus = .notEntered
    @Published var passwordInputStatus: InputStatus = .notEntered
    @Published var allowsSignIn = false
    
    private func validateUsername(_ newUsername: String) {
        usernameInputStatus = !newUsername.isEmpty ? .valid : .invalid
        evaluateIfUserIsAllowedToSignIn()
    }
    
    private func validatePassword(_ newPassword: String) {
        passwordInputStatus = !newPassword.isEmpty ? .valid : .invalid
        evaluateIfUserIsAllowedToSignIn()
    }
              
    /// Evaluates if user is allowed to sign in.
    private func evaluateIfUserIsAllowedToSignIn() {
        allowsSignIn = usernameInputStatus == .valid && passwordInputStatus == .valid
    }
}
