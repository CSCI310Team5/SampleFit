//
//  AuthenticationState.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/17/21.
//

import Foundation
import Combine

/// Manages authentication-related events.
class AuthenticationState: ObservableObject {
    private var _verifiers: AuthenticationVerifiers
    
    // separating instance value from property to allow length capping behavior
    private var _username: String = ""
    var username: String {
        get { _username }
        set {
            objectWillChange.send() // force re-render on every key stroke to reflect length capping behavior
            _usernameWillChange.send(newValue)
        }
    }
    private var _password: String = ""
    var password: String {
        get { _password }
        set {
            objectWillChange.send()
            _passwordWillChange.send(newValue)
        }
    }
    private var _repeatPassword: String = ""
    var repeatPassword: String {
        get { _repeatPassword }
        set {
            objectWillChange.send()
            _repeatPasswordWillChange.send(newValue)
        }
    }
    
    @Published var usernameInputStatus: InputVerificationStatus = .notEntered
    @Published var passwordInputStatus: InputVerificationStatus = .notEntered
    @Published var repeatPasswordInputStatus: InputVerificationStatus = .notEntered
    @Published var allowsAuthentication = false
    
    private var _usernameWillChange = PassthroughSubject<String, Never>()
    private var _passwordWillChange = PassthroughSubject<String, Never>()
    private var _repeatPasswordWillChange = PassthroughSubject<String, Never>()

    // Verifications
    private var _usernameShouldUpdate: AnyCancellable?
    private var _usernameValidation: AnyCancellable?
    
    private var _passwordShouldUpdate: AnyCancellable?
    private var _passwordValidation: AnyCancellable?
    
    private var _repeatAndPasswordPublisher: AnyPublisher<[String], Never>
    private var _repeatPasswordShouldUpdate: AnyCancellable?
    private var _repeatPasswordValidation: AnyCancellable?
    
    private var _allowsAuthenticationCancellable: AnyCancellable?
    
            
    init(for verifiers: AuthenticationVerifiers) {
        self._verifiers = verifiers
        
        // publish input changes to verifier
        self._usernameWillChange.subscribe(_verifiers.username.inputWillChangeSubscriber)
        self._passwordWillChange.subscribe(_verifiers.password.inputWillChangeSubscriber)
        self._repeatAndPasswordPublisher = Publishers.CombineLatest(_repeatPasswordWillChange, _passwordWillChange).map { [$0.0, $0.1] }.eraseToAnyPublisher()
        self._repeatAndPasswordPublisher.subscribe(_verifiers.repeatPassword.inputWillChangeSubscriber)
        
        // length capping
        self._usernameShouldUpdate = _verifiers.username.inputShouldUpdatePublisher
            .assign(to: \._username, on: self)
        self._passwordShouldUpdate = _verifiers.password.inputShouldUpdatePublisher
            .assign(to: \._password, on: self)
        self._repeatPasswordShouldUpdate = _verifiers.repeatPassword.inputShouldUpdatePublisher.map { $0[0] }
            .assign(to: \._repeatPassword, on: self)
                
        // update input status
        self._usernameValidation = _verifiers.username.verificationResultWillChangePublisher
            .assign(to: \.usernameInputStatus, on: self)
        self._passwordValidation = _verifiers.password.verificationResultWillChangePublisher
            .assign(to: \.passwordInputStatus, on: self)
        self._repeatPasswordValidation = _verifiers.repeatPassword.verificationResultWillChangePublisher
            .assign(to: \.repeatPasswordInputStatus, on: self)
        
        if !_verifiers.shouldVerifyUsername { usernameInputStatus = .valid }
        if !_verifiers.shouldVerifyPassword { passwordInputStatus = .valid }
        if !_verifiers.shouldVerifyRepeatPassword { repeatPasswordInputStatus = .valid }
        
        // update allows authentication
        self._allowsAuthenticationCancellable = Publishers.CombineLatest3($usernameInputStatus, $passwordInputStatus, $repeatPasswordInputStatus)
            .map { newValue in
                newValue.0 == .valid && newValue.1 == .valid && newValue.2 == .valid
            }
            .removeDuplicates()
            .assign(to: \.allowsAuthentication, on: self)

    }
    
    // MARK: - Convenience type properties
    static var resetPasswordInformation: AuthenticationState {
        let information = AuthenticationState(for: .changePassword)
        return information
    }
}
