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
    
    // MARK: - Instance properties
    var createAccountAuthenticationState = AuthenticationState(for: .createAccount)
    var signInAuthenticationState = AuthenticationState(for: .signIn)
    var publicProfile = PublicProfile.exampleProfile
    var privateInformation = PrivateInformation()
    var searchCategoryTokenController = SearchCategoryTokenEventController()
    var token = ""
    @Published var signInStatus = SignInStatus.never
    @Published var signInReturnsError = false
    private var networkQueryController = NetworkQueryController()
    
    // MARK: - Navigation
    var shouldPresentAuthenticationView: Bool {
        get { return signInStatus != .signedIn }
        set {}
    }
    
    // MARK: - Asynchronous tasks
    private var _createAccountCancellable: AnyCancellable?
    private var _signInCancellable: AnyCancellable?
    private var _fetchExerciseFeedCancellable: AnyCancellable?
    
    func signInwithAppleDidComplete(with result: Result<ASAuthorization, Error>) {
        switch result {
        case let .success(authorization):
            
            switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                _storeProfileAndManageSignInStatusAfterSignInSuccess(identifier: appleIDCredential.user, fullName: appleIDCredential.fullName)

            case let passwordCredential as ASPasswordCredential:
                _storeProfileAndManageSignInStatusAfterSignInSuccess(identifier: passwordCredential.user)
                
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
    func createAccountUsingDefaultMethod() {
        print("creating account using default method...")
        let oldStatus = signInStatus
        signInStatus = .validatingFirstTime
        signInReturnsError = false
        
        _createAccountCancellable = networkQueryController.createAccount(using: createAccountAuthenticationState)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] success in
                if success {
                    _storeProfileAndManageSignInStatusAfterSignInSuccess(identifier: createAccountAuthenticationState.username)
                } else {
                    print("Create account failed")
                    signInReturnsError = true
                    signInStatus = oldStatus
                }
            }
    }
    
    /// Runs when the user chooses to sign in using default method.
    func signInUsingDefaultMethod() {
        print("signing in using default method...")
        let oldStatus = signInStatus
        signInStatus = .validating
        signInReturnsError = false
        
        _signInCancellable = networkQueryController.signIn(using: signInAuthenticationState)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] success in
                if !success.isEmpty {
                    _storeProfileAndManageSignInStatusAfterSignInSuccess(identifier: signInAuthenticationState.username)
                } else {
                    print("Sign in failed")
                    signInReturnsError = true
                    signInStatus = oldStatus
                }
            }
    }
    
    /// Runs when the user chooses to sign out.
    func signOut() {
        print("signing out.")
        
        signInStatus = .signedOut
        signInAuthenticationState = AuthenticationState(for: .signIn)
    }
    
    func changePassword(to newPassword: String) {
        // FIXME: Change password over the newtwork. Pass in the public profile as the user identifier.
    }
    
    private func _storeProfileAndManageSignInStatusAfterSignInSuccess(identifier: String, fullName: PersonNameComponents? = nil) {
        // store the credentials
        _storeProfile(identifier: identifier, fullName: fullName)
        // change sign in status
        manageSignInStatusAfterSignIn(true)
        // fetch social information
        _fetchExerciseFeeds(usingProfile: publicProfile)
    }
    
    private func _storeProfile(identifier: String, fullName: PersonNameComponents? = nil) {
        publicProfile = PublicProfile(identifier: identifier, fullName: fullName)
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
    
    private func _fetchExerciseFeeds(usingProfile profile: PublicProfile) {
        // fetch social information
        _fetchExerciseFeedCancellable = networkQueryController.exerciseFeedsForUser(withProfile: profile)
            .receive(on: DispatchQueue.main)
            .assign(to: \.privateInformation.exerciseFeeds, on: self)
    }
    
    static var signedInUserData: UserData {
        let userData = UserData()
        userData._storeProfileAndManageSignInStatusAfterSignInSuccess(identifier: "signedInUser")
        userData.privateInformation = PrivateInformation.examplePrivateInformation
        return userData
    }
    
    static var signedOutUserData: UserData {
        let userData = UserData()
        userData.signInStatus = .signedOut
        return userData
    }
}
