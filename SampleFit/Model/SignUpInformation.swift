//
//  SignUpInformation.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/17/21.
//

import Foundation
import Combine

/// Stores information during sign up.
class SignUpInformation: ObservableObject {
    
    /// Notifies SwiftUI to re-render UI because of a data change.
    var objectWillChange = ObservableObjectPublisher()
    
    private var _username: String = ""
    var username: String {
        get { return _username }
        set {
            objectWillChange.send()
            _usernamePassthroughSubject.send(newValue)
            
        }
    }
    private let _usernamePassthroughSubject = PassthroughSubject<String, Never>()
    private var _usernameWillSetCancellable: AnyCancellable?
    private var _usernameShouldValidateCancellable: AnyCancellable?
    
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
    
    var usernameInputStatus: DataEntryStatus = .notEntered
    var passwordInputStatus: DataEntryStatus = .notEntered
    var repeatPasswordInputStatus: DataEntryStatus = .notEntered
    var allowsSignUp = false
            
    init() {
        // when user is still typing in, limit username length and update the username input status to validating
        self._usernameWillSetCancellable =
            _usernamePassthroughSubject
            .filter { $0.count < 16 }
            .removeDuplicates()
            .sink { [unowned self] newValue in
                usernameInputStatus = .validating
                _username = newValue
                evaluateIfUserIsAllowedToSignUp()
            }
        
        // only validate username 1 second after user stopped typing
        self._usernameShouldValidateCancellable =
            _usernamePassthroughSubject
            .filter { $0.count < 16 }
            .removeDuplicates()
            .debounce(for: .seconds(1.0), scheduler: DispatchQueue.global())
            .sink { newValue in
                self.validateUsername(newValue)
            }
    }
    
    
    private func validateUsername(_ newUsername: String) {
        
        // TODO: Check with backend to validate username
        if newUsername.count > 4 {
            usernameInputStatus = .valid
        } else {
            usernameInputStatus = .invalid
        }
        
        evaluateIfUserIsAllowedToSignUp()
    }
    
    private func validatePassword(_ newPassword: String) {
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
        
        evaluateIfUserIsAllowedToSignUp()
    }
        
    private func validateRepeatPassword(_ newRepeatPassword: String) {
        if password == newRepeatPassword {
            repeatPasswordInputStatus = .valid
        } else {
            repeatPasswordInputStatus = .invalid
        }
        
        evaluateIfUserIsAllowedToSignUp()
    }
      
    /// Evaluates if user is allowed to sign up.
    private func evaluateIfUserIsAllowedToSignUp() {
        allowsSignUp = usernameInputStatus == .valid
            && passwordInputStatus == .valid
            && repeatPasswordInputStatus == .valid
        
        publishChangeOnMainThread()
    }

    private func publishChangeOnMainThread() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}
