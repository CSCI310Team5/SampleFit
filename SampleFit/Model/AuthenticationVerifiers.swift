//
//  AuthenticationVerifiers.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/9/21.
//

import Foundation
import Combine

/// Each AuthenticationState requires an authentication verifier to specify the verification logic.
struct AuthenticationVerifiers {
    var username: InputVerifier<String>
    var password: InputVerifier<String>
    var repeatPassword: InputVerifier<[String]>
    var shouldVerifyUsername: Bool
    var shouldVerifyPassword: Bool
    var shouldVerifyRepeatPassword: Bool
    
    init(username: InputVerifier<String>?, password: InputVerifier<String>?, repeatPassword: InputVerifier<[String]>?) {
        self.username = username ?? InputVerifier<String>()
        self.password = password ?? InputVerifier<String>()
        self.repeatPassword = repeatPassword ?? InputVerifier<[String]>()
        self.shouldVerifyUsername = (username != nil)
        self.shouldVerifyPassword = (password != nil)
        self.shouldVerifyRepeatPassword = (repeatPassword != nil)
    }

    // limit max username length, check only 1 second after consecutive changes
    private static let _usernameCreateAccountVerifier = InputVerifier<String>(debounce: .seconds(1), scheduler: DispatchQueue.main, limit: 20) { NetworkQueryController.shared.validateUsername($0)
        .map { $0 ? InputVerificationStatus.valid : InputVerificationStatus.invalid }
        .eraseToAnyPublisher()
    }
    // limit max password length
    private static let _passwordCreateAccountVerifier = InputVerifier<String>(debounce: .seconds(1), scheduler: DispatchQueue.main, limit: 20) {
        NetworkQueryController.shared.validatePassword($0)
            .map { $0 ? InputVerificationStatus.valid : InputVerificationStatus.invalid }
            .eraseToAnyPublisher()
    }
    private static let _repeatPasswordVerifier = InputVerifier<[String]>(debounce: .zero, scheduler: DispatchQueue.main, limit: 20) {
        Just($0[0] == $0[1])
            .map { $0 ? InputVerificationStatus.valid : InputVerificationStatus.invalid }
            .eraseToAnyPublisher()
    }
    private static func _passThroughVerifier() -> InputVerifier<String> {
        return InputVerifier<String>(debounce: .zero, scheduler: DispatchQueue.main) { _ in
            Just(true)
                .map { $0 ? InputVerificationStatus.valid : InputVerificationStatus.invalid }
                .eraseToAnyPublisher()
        }
    }
    
    static let createAccount = AuthenticationVerifiers(username: _usernameCreateAccountVerifier, password: _passwordCreateAccountVerifier, repeatPassword: _repeatPasswordVerifier)
    static let signIn = AuthenticationVerifiers(username: _passThroughVerifier(), password: _passThroughVerifier(), repeatPassword: nil)
    static let changePassword = AuthenticationVerifiers(username: nil, password: _passwordCreateAccountVerifier, repeatPassword: _repeatPasswordVerifier)
}
