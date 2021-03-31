//
//  SampleFitUITests.swift
//  SampleFitUITests
//
//  Created by Zihan Qi on 2/10/21.
//

import XCTest

class RegisterSignInUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func createAccountLaunchHelper(success: Bool) -> XCUIApplication{
        let app = XCUIApplication()
        app.launch()
        
        let emailTextField = app.textFields["Email"]
        emailTextField.tap()
        
        let uniqueSeed = UUID().description.prefix(8)
        emailTextField.typeText("\(uniqueSeed)@usc.edu")
        
        var password = "AAA111333"
        if !success{ password = "aaaaaaaaa" }
        
        let passwordSecureField = app.secureTextFields[.localIdentifier(for: .passwordSecureField)]
        passwordSecureField.tap()
        passwordSecureField.typeText(password)
        
        let repeatPasswordSecureField = app.secureTextFields[.localIdentifier(for: .repeatPasswordSecureField)]
        repeatPasswordSecureField.tap()
        repeatPasswordSecureField.typeText(password)
        
        return app
    }
    
    func testCreateAccount() throws {
        // UI tests must launch the application that they test.
        let app = createAccountLaunchHelper(success: true)
        
        sleep(3)
        
        let createAccountButton = app.buttons[.localIdentifier(for: .createAccountButton)]
        
        XCTAssertTrue(createAccountButton.isEnabled, "Create Account Button should be enabled")
    }
    
    func testSuccessfulCreateAccount() throws {
        let app = createAccountLaunchHelper(success: true)
        
        sleep(3)
        
        let createAccountButton = app.buttons[.localIdentifier(for: .createAccountButton)]
        
        XCTAssertTrue(createAccountButton.isEnabled, "Create Account Button should be enabled")
        
        createAccountButton.tap()
        
        sleep(3)
        
        XCTAssert(app.staticTexts["Me"].exists)
        
    }
    
    func testFailureCreateAccount() throws {
        let app = createAccountLaunchHelper(success: false)
        
        sleep(3)
        
        let createAccountButton = app.buttons[.localIdentifier(for: .createAccountButton)]
        
        XCTAssertTrue(createAccountButton.isEnabled, "Create Account Button should be enabled")
        
        createAccountButton.tap()
        
        sleep(3)
        
        XCTAssert(!app.staticTexts["Me"].exists)
        
    }
    
    func SignInHelper(email:String, password: String) -> XCUIApplication {
        
        let app = XCUIApplication()
        app.launch()
        
        XCUIApplication().navigationBars["Sign Up"].buttons["Log In"].tap()
        
        let emailTextField = app.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText(email)
        
        let passwordSecureField = app.secureTextFields[.localIdentifier(for: .passwordSecureField)]
        passwordSecureField.tap()
        passwordSecureField.typeText(password)
        
        return app
    }
    
    func testSignIn() throws {
        // UI tests must launch the application that they test.
        
        let uniqueSeed = UUID().description.prefix(8)
        let app = SignInHelper(email: "\(uniqueSeed)@usc.edu", password: "aaa666999")
        
        sleep(3)
        
        let signInButton = app.buttons[.localIdentifier(for: .signInButton)]
        
        XCTAssertTrue(signInButton.isEnabled, "Sign In Button should be enabled")
    }
    
    func testFailureSignIn() throws {
        // UI tests must launch the application that they test.
        let app = SignInHelper(email: "shuyaoxi@usc.edu", password: "aaa666777")
        
        sleep(1)
        
        let signInButton = app.buttons[.localIdentifier(for: .signInButton)]
        
        XCTAssertTrue(signInButton.isEnabled, "Sign In Button should be enabled")
        
        signInButton.tap()
        
        sleep(2)
        
        XCTAssertTrue(!app.staticTexts["Me"].exists)
    }
    
    func testSuccessfulSignIn() throws {
        // UI tests must launch the application that they test.
        let app = SignInHelper(email: "shuyaoxi@usc.edu", password: "aaa666999")
        
        sleep(1)
        
        let signInButton = app.buttons[.localIdentifier(for: .signInButton)]
        
        XCTAssertTrue(signInButton.isEnabled, "Sign In Button should be enabled")
        
        signInButton.tap()
        
        sleep(2)
        
        XCTAssertTrue(app.staticTexts["Me"].exists)
    }
}
