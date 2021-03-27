//
//  SampleFitTests.swift
//  SampleFitTests
//
//  Created by Zihan Qi on 2/10/21.
//

import XCTest
@testable import SampleFit

class SampleFitTests: XCTestCase {
    
    var userData: UserData!

    override func setUpWithError() throws {
        userData = UserData()
        userData.signInStatus = .never

        let usernames =  ["zihanqi@usc.edu", "shuyaoxi@usc.edu"]
        let passwords = ["AAA111333", "aaa666999"]
        
        let currentUsername = usernames.randomElement()!
        let currentPassword = passwords.randomElement()!
        
        userData.createAccountAuthenticationState.username = currentUsername
        userData.createAccountAuthenticationState.password = currentPassword
        userData.signInAuthenticationState.username = currentUsername
        userData.signInAuthenticationState.password = currentPassword
    }

    override func tearDownWithError() throws {}

    func testUserDataCreateAccount() throws {
        userData.manageSignInStatusAfterSignIn(true)

        XCTAssertEqual(userData.signInStatus, SignInStatus.signedIn, "UserData sign in status should become .signedIn.")
    }
    
    func testUserDataSignOut() throws {
        userData.signOut()
        
        XCTAssertEqual(userData.signInStatus, SignInStatus.signedOut, "UserData sign in status should become .signedOut.")
    }
    
    func testUserDataSignIn() throws {
        userData.signOut()
        userData.manageSignInStatusAfterSignIn(true)
        
        XCTAssertEqual(userData.signInStatus, SignInStatus.signedIn, "UserData sign in status should become .signedIn.")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
