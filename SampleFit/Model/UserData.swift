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
    
    /// Stores information during sign up.
    class SignUpInformation: ObservableObject {
        
        /// Notifies SwiftUI to re-render UI because of a data change.
        var objectWillChange = ObservableObjectPublisher()
        
        private var _username: String = ""
        var username: String {
            get { return _username }
            set {
                objectWillChange.send()
                usernamePassthroughSubject.send(newValue)
                
            }
        }
        private let usernamePassthroughSubject = PassthroughSubject<String, Never>()
        private var usernameWillSetCancellable: AnyCancellable?
        private var usernameShouldValidateCancellable: AnyCancellable?
        
        var password: String = "" {
            willSet {
                validatePassword(newValue)
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
                
        init() {
            // when user is still typing in, limit username length and update the username input status to validating
            self.usernameWillSetCancellable =
                usernamePassthroughSubject
                .filter { $0.count < 16 }
                .removeDuplicates()
                .sink { [unowned self] newValue in
                    usernameInputStatus = .validating
                    _username = newValue
                    evaluateIfUserIsAllowedToSignUp()
                }
            
            // only validate username 1 second after user stopped typing
            self.usernameShouldValidateCancellable =
                usernamePassthroughSubject
                .filter { $0.count < 16 }
                .removeDuplicates()
                .debounce(for: .seconds(1.0), scheduler: DispatchQueue.global())
                .sink { newValue in
                    self.validateUsername(newValue)
                }
        }
        
        
        func validateUsername(_ newUsername: String) {
            
            // TODO: Check with backend to validate username
            if newUsername.count > 4 {
                usernameInputStatus = .valid
            } else {
                usernameInputStatus = .invalid
            }
            
            evaluateIfUserIsAllowedToSignUp()
        }
        
        func validatePassword(_ newPassword: String) {
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
            
        func validateRepeatPassword(_ newRepeatPassword: String) {
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
    
    /// Stores information during sign in.
    class SignInInformation: ObservableObject {
        @Published var username: String = "" {
            willSet {
                validateUsername(newValue)
            }
        }
        @Published var password: String = "" {
            willSet {
                validatePassword(newValue)
            }
        }
        
        @Published var usernameInputStatus: DataEntryStatus = .notEntered
        @Published var passwordInputStatus: DataEntryStatus = .notEntered
        @Published var allowsSignIn = false
        
        func validateUsername(_ newUsername: String) {
            usernameInputStatus = !newUsername.isEmpty ? .valid : .invalid
            evaluateIfUserIsAllowedToSignIn()
        }
        
        func validatePassword(_ newPassword: String) {
            passwordInputStatus = !newPassword.isEmpty ? .valid : .invalid
            evaluateIfUserIsAllowedToSignIn()
        }
                  
        /// Evaluates if user is allowed to sign in.
        private func evaluateIfUserIsAllowedToSignIn() {
            allowsSignIn = usernameInputStatus == .valid && passwordInputStatus == .valid
        }
    }
    
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
    var shouldPresentMainView: Bool {
        get { return signInStatus == .signedIn }
        set {  }
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
