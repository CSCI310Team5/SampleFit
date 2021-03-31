//
//  LikeListUITests.swift
//  SampleFitUITests
//
//  Created by Zihan Qi on 3/30/21.
//

import XCTest

class LikeListUITests: XCTestCase {
    var app: XCUIApplication!
    
    func signIn(app: XCUIApplication) {
        XCUIApplication().navigationBars["Sign Up"].buttons["Log In"].tap()
        
        let emailTextField = app.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText("shuyaoxi@usc.edu")
        
        let passwordSecureField = app.secureTextFields[.localIdentifier(for: .passwordSecureField)]
        passwordSecureField.tap()
        passwordSecureField.typeText("aaa666999")
        
        sleep(1)
        
        let signInButton = app.buttons[.localIdentifier(for: .signInButton)]
        
        XCTAssertTrue(signInButton.isEnabled, "Sign In Button should be enabled")
        
        signInButton.tap()
        
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        signIn(app: app)
    }

    override func tearDownWithError() throws {}

    func testAddAndRemoveExericseFromLikeList() throws {
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["Video & Live"].tap()
        let scrollViewsQuery = app.scrollViews
        scrollViewsQuery.otherElements.containing(.button, identifier:"Pushup with Jessie, Lets do some pushups!").element.swipeUp()
        
        app.buttons["·, Cycling, Cycling with Jessie"].tap()
        app.buttons["star"].tap()
        tabBar.buttons["Me"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.buttons["Favorites"].tap()
        XCTAssert(tablesQuery.buttons["·, Cycling, Cycling with Jessie"].isHittable)
        tablesQuery.buttons["·, Cycling, Cycling with Jessie"].tap()
        
        app.buttons["star.fill"].tap()
        app.navigationBars["Cycling with Jessie"].buttons["Favorites"].tap()
        
        XCTAssertFalse(tablesQuery.buttons["·, Cycling, Cycling with Jessie"].isHittable)
    }

}
