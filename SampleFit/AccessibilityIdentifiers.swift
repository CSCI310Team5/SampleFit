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
    case userNickname
    case userHeight
    case userWeight
    case userBirthday
    case uploadMediaTypeToggle
    case uploadNameTextField
    case uploadDescriptionTextField
    case uploadLinkTextfield
    case uploadsSection
    case uploadNewButton
    case uploadsList
    case exerciseName
}

extension String {
    static func localIdentifier(for identifier: AccessibilityIdentifiers) -> String {
        return identifier.rawValue
    }
}
