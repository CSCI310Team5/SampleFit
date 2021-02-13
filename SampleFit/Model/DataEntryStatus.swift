//
//  DataEntryStatus.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import Foundation
import SwiftUI

/// Indicates the input status of an entry of information.
enum DataEntryStatus {
    case notEntered
    case validating
    case valid
    case invalid
    /// Color that represents the sign up input status.
    var signUpColor: Color {
        switch self {
        case .notEntered, .validating:
            return Color.primary
        case .valid:
            return Color.green
        case .invalid:
            return Color.red
        }
    }
    /// Color that represents the sign in input status.
    var signInColor: Color {
        switch self {
        case .notEntered, .validating:
            return Color.primary
        case .valid:
            return Color.accentColor
        case .invalid:
            return Color.red
        }
    }
}
