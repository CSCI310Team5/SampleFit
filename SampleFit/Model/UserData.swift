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
    
    /// Stores user credential.
    class Credential {
        var identifier: String = ""
        var fullName: PersonNameComponents?
        
        init() {}
        init(identifier: String, fullName: PersonNameComponents?) {
            self.identifier = identifier
            self.fullName = fullName
        }
    }
    
    // MARK: - Instance properties
    
    /// Notifies SwiftUI to re-render UI because of a data change.
    var objectWillChange = ObservableObjectPublisher()
    
    var signUpInformation = SignUpInformation()
    var signInInformation = SignInInformation()
    var credential = Credential()
    var signInStatus = SignInStatus.never {
        willSet {
            objectWillChange.send()
        }
    }
    
    // MARK: - Navigation
    var shouldPresentAuthenticationView: Bool {
        get { return signInStatus != .signedIn }
        set {}
    }
    
    // MARK: - Sign in/out methods
    
    func signInwithAppleDidComplete(with result: Result<ASAuthorization, Error>) {
        switch result {
        case let .success(authorization):
            
            switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                storeCredentialAndManageSignInStatusAfterSignInSuccess(identifier: appleIDCredential.user, fullName: appleIDCredential.fullName)

            case let passwordCredential as ASPasswordCredential:
                storeCredentialAndManageSignInStatusAfterSignInSuccess(identifier: passwordCredential.user)
                
            default:
                break
            }
            
            
        case let .failure(error):
            
            // TODO: Do something about the error
            print("Sign in with Apple Error: \(error)")
            manageSignInStatusAfterSignIn(false)
            
        }
    }
    
    /// Runs when the user chooses to sign up using default method.
    func signUpUsingDefaultMethod() {
        print("creating account using default method...")
        // TODO: Create account over the network
        
        // FIXME: Assuming success for now
        storeCredentialAndManageSignInStatusAfterSignInSuccess(identifier: signUpInformation.username)
    }
    
    /// Runs when the user chooses to sign in using default method.
    func signInUsingDefaultMethod() {
        print("signing in using default method...")
        // TODO: Sign in over the network
        
        // FIXME: Assuming success for now
        storeCredentialAndManageSignInStatusAfterSignInSuccess(identifier: signInInformation.username)
    }
    
    /// Runs when the user chooses to sign out.
    func signOut() {
        print("signing out.")
        
        signInStatus = .signedOut
    }
    
    private func storeCredentialAndManageSignInStatusAfterSignInSuccess(identifier: String, fullName: PersonNameComponents? = nil) {
        storeCredential(identifier: identifier, fullName: fullName)
        manageSignInStatusAfterSignIn(true)
    }
    
    private func storeCredential(identifier: String, fullName: PersonNameComponents? = nil) {
        credential = Credential(identifier: identifier, fullName: fullName)
    }
    
    /// Manages sign in status after the user chooses to sign in.
    private func manageSignInStatusAfterSignIn(_ success: Bool) {
        if success {
            signInStatus = .signedIn
        } else {
            switch signInStatus {
            case .never:
                break
            default:
                signInStatus = .signedOut
            }
        }
    }
}
