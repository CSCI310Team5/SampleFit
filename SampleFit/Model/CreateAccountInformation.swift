//
//  CreateAccountInformation.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/17/21.
//

import Foundation
import Combine

/// Stores information during sign up.
class CreateAccountInformation: ObservableObject {
    
    /// Notifies SwiftUI to re-render UI because of a data change.
    var objectWillChange = ObservableObjectPublisher()
    
    private var _username: String = ""
    var username: String {
        get { return _username }
        set {
            _validateUsername(newValue)
            _usernameWillChangePublisher.send(newValue)
        }
    }
    var password: String = "" {
        willSet {
            _validatePassword(newValue)
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
    
    private let _usernameWillChangePublisher = PassthroughSubject<String, Never>()
    private var _usernameShouldUpdateCancellable: AnyCancellable?
    private var _usernameShouldValidateCancellable: AnyCancellable?
    private var _usernameValidationCancellable: AnyCancellable?
            
    init() {
        // when user is still typing in, limit username length and update the username input status to validating
        self._usernameShouldUpdateCancellable = _usernameWillChangePublisher
            .filter { $0.count < 16 }
            .removeDuplicates()
            .sink { [unowned self] newValue in
                // when the user types in, change input status to validating
                usernameInputStatus = .validating
                _username = newValue
                objectWillChange.send()
            }
        
        // only validate username 1 second after user stopped typing
        self._usernameShouldValidateCancellable = _usernameWillChangePublisher
            .filter { $0.count < 16 }
            .removeDuplicates()
            .debounce(for: .seconds(1.0), scheduler: DispatchQueue.global())
            .sink { newValue in
                self._validateUsername(newValue)
            }
    }
    
    
    private func _validateUsername(_ newUsername: String) {
        _usernameValidationCancellable?.cancel()
        
        _usernameValidationCancellable = NetworkQueryController.shared.validateUsername(newUsername)
            .receive(on: DispatchQueue.main)
            .map { $0 ? DataEntryStatus.valid : DataEntryStatus.invalid }
            .sink {
                self.usernameInputStatus = $0
                self.evaluateIfUserIsAllowedToSignUp()
            }
    }
    
    private func _validatePassword(_ newPassword: String) {
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
