//
//  SignInStatus.swift
//  SampleFit
//
//  Created by Zihan Qi on 2/11/21.
//

import Foundation

/// Indicates the sign in status.
enum SignInStatus {
    case never
    case validatingFirstTime
    case validating
    case signedIn
    case signedOut
}
