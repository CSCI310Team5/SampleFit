//
//  AccessibilityIdentifiers.swift
//  SampleFit
//
//  Created by Zihan Qi on 3/24/21.
//

import Foundation

enum AccessibilityIdentifiers: String {
    case toggleToSignInButton
    case toggleToSignUpButton
    case usernameTextField
    case passwordSecureField
    case repeatPasswordSecureField
    case createAccountButton
    case signInButton
    case profileAvatar
}

extension String {
    static func localIdentifier(for identifier: AccessibilityIdentifiers) -> String {
        return identifier.rawValue
    }
}
