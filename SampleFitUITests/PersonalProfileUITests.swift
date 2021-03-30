//
//  PersonalProfileUITests.swift
//  SampleFitUITests
//
//  Created by apple on 3/30/21.
//

import XCTest

class PersonalProfileUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false


        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    func SignInHelper() -> XCUIApplication {
        
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
        
        return app
    }

    func testProfileView() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let app = SignInHelper()
        XCTAssertTrue(app.tables/*@START_MENU_TOKEN@*/.buttons["Profile Details"]/*[[".cells[\"Profile Details\"].buttons[\"Profile Details\"]",".buttons[\"Profile Details\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists)
        app.tables.buttons["Profile Details"].tap()
        XCTAssertTrue(app.staticTexts["Nickname"].exists)
        XCTAssertTrue(app.staticTexts["Date of Birth"].exists)
        XCTAssertTrue(app.staticTexts["Height"].exists)
        XCTAssertTrue(app.staticTexts["Weight"].exists)
        XCTAssertTrue(app.images[.localIdentifier(for: .profileAvatar)].exists)
    }
    
    func 
}
