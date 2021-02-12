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

/// Stores relavant information about the user.
class UserData: ObservableObject {
    
    // MARK: Instance properties
    
    /// Notifies SwiftUI to re-render UI because of a data change.
    var objectWillChange = ObservableObjectPublisher()
    
    /// Indicates the input status of an entry of user information like username, password, etc.
    enum InputStatus {
        case notEntered
        case validating
        case valid
        case invalid
        /// Color that represents the input status.
        var color: Color {
            switch self {
            case .notEntered, .validating:
                return Color.primary
            case .valid:
                return Color.green
            case .invalid:
                return Color.red
            }
        }
    }
    
    private var _username: String = ""
    var username: String {
        get { return _username }
        set {
            objectWillChange.send()
            usernamePassthroughSubject.send(newValue)
            
        }
    }
    private let usernamePassthroughSubject = PassthroughSubject<String, Never>()
    private var usernameWillSetCancellable: AnyCancellable?
    private var usernameShouldValidateCancellable: AnyCancellable?
    
    var password: String = "" {
        willSet {
            validatePassword(newValue)
        }
    }
    var repeatPassword: String = "" {
        willSet {
            validateRepeatPassword(newValue)
        }
    }
    
    var usernameInputStatus: InputStatus = .notEntered
    var passwordInputStatus: InputStatus = .notEntered
    var repeatPasswordInputStatus: InputStatus = .notEntered
    var userAuthenticationSignUpStatusDidValidate = false
    
    // MARK: - Initializers
    
    init() {
        // when user is still typing in, limit username length and update the username input status to validating
        self.usernameWillSetCancellable =
            usernamePassthroughSubject
            .filter { $0.count < 16 }
            .removeDuplicates()
            .sink { [unowned self] newValue in
                usernameInputStatus = .validating
                _username = newValue
                evaluateUserAuthenticationSignUpStatus()
            }
        
        // only validate username 1 second after user stopped typing
        self.usernameShouldValidateCancellable =
            usernamePassthroughSubject
            .filter { $0.count < 16 }
            .removeDuplicates()
            .debounce(for: .seconds(1.0), scheduler: DispatchQueue.global())
            .sink { newValue in
                self.validateUsername(newValue)
            }
    }
    
    // MARK: - Instance methods
    
    func validateUsername(_ newUsername: String) {
        
        // TODO: Check with backend to validate username
        if newUsername.count > 4 {
            usernameInputStatus = .valid
        } else {
            usernameInputStatus = .invalid
        }
        
        evaluateUserAuthenticationSignUpStatus()
    }
    
    func validatePassword(_ newPassword: String) {
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
        
    func validateRepeatPassword(_ newRepeatPassword: String) {
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
        
        publishChangeOnMainThread()
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

// MARK: - Helpers

extension UserData {
    private func publishChangeOnMainThread() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}
