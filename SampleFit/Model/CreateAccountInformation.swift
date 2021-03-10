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
    
    @Published var usernameInputStatus: InputStatus = .notEntered
    @Published var passwordInputStatus: InputStatus = .notEntered
    @Published var repeatPasswordInputStatus: InputStatus = .notEntered
    @Published var allowsSignUp = false
    
    private var _usernameWillChange = PassthroughSubject<String, Never>()
    private var _passwordWillChange = PassthroughSubject<String, Never>()
    private var _repeatPasswordWillChange = PassthroughSubject<String, Never>()

    // Verifications
    private var _usernameVerifier: InputVerifier<String>!
    private var _usernameShouldUpdate: AnyCancellable?
    private var _usernameValidation: AnyCancellable?
    
    private var _passwordVerifier: InputVerifier<String>!
    private var _passwordShouldUpdate: AnyCancellable?
    private var _passwordValidation: AnyCancellable?
    
    private var _repeatPasswordVerfier: InputVerifier<String>!
    private var _repeatPasswordShouldUpdate: AnyCancellable?
    private var _repeatPasswordValidation: AnyCancellable?
    
    private var _allowsSignUpCancellable: AnyCancellable?
    
            
    init() {
        let usernameLimit = 16
        let passwordLimit = 20
        // limit max username length, check only 1 second after consecutive changes
        self._usernameVerifier = InputVerifier<String>(debounce: .seconds(1), scheduler: DispatchQueue.main, limit: usernameLimit) { NetworkQueryController.shared.validateUsername($0)
                .map { $0 ? InputStatus.valid : InputStatus.invalid }
                .eraseToAnyPublisher()
        }
        // limit max password length
        self._passwordVerifier = InputVerifier<String>(debounce: .zero, scheduler: DispatchQueue.main, limit: passwordLimit) {
            Just($0.count >= 5)
                .map { $0 ? InputStatus.valid : InputStatus.invalid }
                .eraseToAnyPublisher()
        }
        self._repeatPasswordVerfier = InputVerifier<String>(debounce: .zero, scheduler: DispatchQueue.main, limit: passwordLimit) {
            Just($0 == self.password)
                .map { $0 ? InputStatus.valid : InputStatus.invalid }
                .eraseToAnyPublisher()
        }
        
        // attach publisher to verifier
        self._usernameWillChange.subscribe(_usernameVerifier.inputWillChangeSubscriber)
        self._passwordWillChange.subscribe(_passwordVerifier.inputWillChangeSubscriber)
        self._repeatPasswordWillChange.subscribe(_repeatPasswordVerfier.inputWillChangeSubscriber)
        
        // length capping
        self._usernameShouldUpdate = _usernameVerifier.inputShouldUpdatePublisher
            .assign(to: \._username, on: self)
        self._passwordShouldUpdate = _passwordVerifier.inputShouldUpdatePublisher
            .assign(to: \._password, on: self)
        self._repeatPasswordShouldUpdate = _repeatPasswordVerfier.inputShouldUpdatePublisher
            .assign(to: \._repeatPassword, on: self)
        
        // update input status
        self._usernameValidation = _usernameVerifier.verificationResultWillChangePublisher
            .assign(to: \.usernameInputStatus, on: self)
        self._passwordValidation = _passwordVerifier.verificationResultWillChangePublisher
            .assign(to: \.passwordInputStatus, on: self)
        self._repeatPasswordValidation = _repeatPasswordVerfier.verificationResultWillChangePublisher
            .assign(to: \.repeatPasswordInputStatus, on: self)
        
        // update allows sign up
        self._allowsSignUpCancellable = Publishers.CombineLatest3($usernameInputStatus, $passwordInputStatus, $repeatPasswordInputStatus)
            .map { newValue in
                newValue.0 == .valid && newValue.1 == .valid && newValue.2 == .valid
            }
            .removeDuplicates()
            .assign(to: \.allowsSignUp, on: self)
    }
    
    // MARK: - Convenience type properties
    static var resetPasswordInformation: CreateAccountInformation {
        let information = CreateAccountInformation()
        information.usernameInputStatus = .valid
        return information
    }
}
