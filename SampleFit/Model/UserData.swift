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
    var publicProfile = PublicProfile(identifier: "", fullName: nil)
    var privateInformation = PrivateInformation()
    var searchCategoryTokenController = SearchCategoryTokenEventController()
    
    //MARK: RECORD TOKEN WHEN LOGGED IN
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
    private var _profileCancellable : AnyCancellable?
    private var _newPasswordCancellable: AnyCancellable?
    private var _getWorkoutHistoryCancellable: AnyCancellable?
    private var _retrievePasswordCancellable : AnyCancellable?
    private var _emailCheckCancellable: AnyCancellable?
    private var _avatarCancellable: AnyCancellable?
    private var _fetchLivestreamCancellable : AnyCancellable?
    private var _fetchVideoCancellable : AnyCancellable?
    private var _fectchFolloweeUploadsCancellable: AnyCancellable?
    private var _deleteAccountCancellable : AnyCancellable?
    
    @Published var changeDone: Int = 0
    
 
    func retrievePassword(email:String){
        
        _retrievePasswordCancellable = networkQueryController.retrievePassword(email)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] valid in
                print("return\(valid)")
                if valid == true {
                    changeDone=1
                }else{
                    changeDone=3
                }
            }
    }
    
    func deleteAccount(){
        _deleteAccountCancellable = networkQueryController.deleteAccount(email: publicProfile.identifier, token: token)
            .receive(on: DispatchQueue.main)
            .sink{ [unowned self] done in
                self.signOut()
            }
    }
    
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
            .sink { [unowned self]  token in
                if !token.isEmpty {
                    self.token=token
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
            .sink { [unowned self] token in
                if !token.isEmpty {
                    self.token=token
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
        privateInformation.removeProfile()
        publicProfile.removeProfile()
        
    }
    
    func changePassword(to newPassword: String) {
        _newPasswordCancellable=networkQueryController.changePassword(email: publicProfile.identifier, newPassword: newPassword, token: token)
            .receive(on: DispatchQueue.main)
            .sink {_ in
                
            }
    }
    
    private func _storeProfileAndManageSignInStatusAfterSignInSuccess(identifier: String, fullName: PersonNameComponents? = nil) {
        // store the credentials
        _storeProfile(identifier: identifier, fullName: fullName)
        // change sign in status
        manageSignInStatusAfterSignIn(true)
    }
    
    func _storeProfile(identifier: String, fullName: PersonNameComponents? = nil) {
        
        privateInformation.storeWorkoutHistory(token: token, email: identifier)
        privateInformation.email = identifier

        
        _profileCancellable = networkQueryController.getProfile(email: identifier, token: token)
            .receive(on: DispatchQueue.main)
            .sink{[unowned self] token in

                self.publicProfile.identifier = identifier

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                var date: Date?
                if token.birthday != nil { date = formatter.date(from: token.birthday!)}
                self.publicProfile.setProfile(weight: token.weight, height: token.height, nickname: token.nickname, birthday: date ?? nil)

                if token.avatar != nil {
                    _avatarCancellable=networkQueryController.loadImage(fromURL: URL(string: "http://127.0.0.1:8000\(token.avatar!)")!).receive(on: DispatchQueue.main)
                        .sink{[unowned self] avatar in
                            self.publicProfile.image=avatar}
                }
                publicProfile.authenticationToken = self.token
                privateInformation.authenticationToken = self.token
                privateInformation.email = identifier
                
                privateInformation.getFollowList(token: self.token, email: identifier)
                privateInformation.getFavoriteExercises(email: identifier, token: self.token)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5){[unowned self] in
                    privateInformation.getSearchHistory(token: self.token, email: identifier)
                    
                    // fetch social information
                    fetchExerciseFeeds()
                }
            }
        
     
        
    }
    
    /// Manages sign in status after the user chooses to sign in.
    func manageSignInStatusAfterSignIn(_ success: Bool) {
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
    
    func fetchExerciseFeeds() {
        DispatchQueue.main.async {
            self.privateInformation.exerciseFeeds = []
        }
        self.fetchLiveFeeds(token: token)
        self.fetchVideoFeeds(token: token)
        self.fetchFolloweeVideoUploads()
    }
    
    func fetchLiveFeeds( token: String) {
        _fetchLivestreamCancellable = networkQueryController.getAllLivestream(token: token)
            .receive(on: DispatchQueue.main)
            .sink { newExercises in
                DispatchQueue.main.async {
                    self.privateInformation.exerciseFeeds.append(contentsOf: newExercises)
                }
            }
    }
    func fetchVideoFeeds(token: String){
        _fetchVideoCancellable = networkQueryController.getAllVideo(token: token)
            .receive(on: DispatchQueue.main)
            .sink { newExercises in
                DispatchQueue.main.async {
                    self.privateInformation.exerciseFeeds.append(contentsOf: newExercises)
                }
            }
    }
    
    private func fetchFolloweeVideoUploads() {
        // FIXME: - Implement this
        _fectchFolloweeUploadsCancellable = networkQueryController.getFolloweeVideoUploads(token: token, email: publicProfile.identifier)
            .receive(on: DispatchQueue.main)
            .sink {
                self.privateInformation.followeeVideoUploads = $0
            }
    }
    
    static var signedInUserData: UserData {
        let userData = UserData()
        userData.signInAuthenticationState.username = "zihanqi@usc.edu"
        userData.signInAuthenticationState.password = "zihanqiusc"

        return userData
    }
    
    static var signedOutUserData: UserData {
        let userData = UserData()
        userData.signInStatus = .signedOut
        return userData
    }
}
