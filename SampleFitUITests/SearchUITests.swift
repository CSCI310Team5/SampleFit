//
//  SearchUITests.swift
//  SampleFitUITests
//
//  Created by Zihan Qi on 3/30/21.
//

import XCTest

class SearchUITests: XCTestCase {
    
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

    override func tearDownWithError() throws {
    }

    func testSearch() throws {
        app.tabBars["Tab Bar"].buttons["Search"].tap()
        app.navigationBars["Search"].searchFields["Videos, Users"].tap()
        app.scrollViews.otherElements.buttons["HIIT"].tap()
        
        XCTAssert(app.tables.buttons["·, HIIT, HIIT with Jessie"].isHittable)
    }

}
