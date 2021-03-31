//
//  PersonalInterfaceUITest.swift
//  SampleFitUITests
//
//  Created by apple on 3/30/21.
//

import XCTest

class PersonalInterfaceUITest: XCTestCase {

    func signin(){
        let app = XCUIApplication()
        app.launch()
        
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
        
        sleep(1)
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        signin()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testChangePassword() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let app = XCUIApplication()
        
        XCTAssertTrue(app.buttons["Password & Security"].exists)
        
        app.buttons["Password & Security"].tap()
        
        XCTAssertTrue(app.buttons["Change Password"].exists)
        
        app.buttons["Change Password"].tap()
        
        XCTAssertTrue(app.secureTextFields.count==2)
    }

}
