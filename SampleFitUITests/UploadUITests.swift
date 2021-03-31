//
//  UploadUITests.swift
//  SampleFitUITests
//
//  Created by Zihan Qi on 3/30/21.
//

import XCTest

class UploadUITests: XCTestCase {
    
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
    
    func uniqueString() -> String {
        let uniqueSeed = UUID().description.prefix(8)
        return String(uniqueSeed)
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        signIn(app: app)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUploadLivestream() throws {
        
        let tablesQuery = app.tables
        tablesQuery.buttons["uploadsSection"].tap()
        app.navigationBars["Uploads"].buttons["uploadNewButton"].tap()
        sleep(1)
        tablesQuery.switches["uploadMediaTypeToggle"].tap()
        
        let randomString = uniqueString()
        let uploadNameTextField = tablesQuery.textFields["uploadNameTextField"]
        uploadNameTextField.tap()
        uploadNameTextField.typeText(randomString)
        
        let uploadDescriptionTextField = app.tables.textFields["uploadDescriptionTextField"]
        uploadDescriptionTextField.tap()
        uploadDescriptionTextField.typeText(randomString)
        XCUIApplication()/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let uploadlinktextfieldTextField = tablesQuery.textFields["uploadLinkTextfield"]
        uploadlinktextfieldTextField.tap()
        uploadlinktextfieldTextField.typeText("https://google.com/\(randomString)")
        
        XCUIApplication()/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()

        app.buttons["Confirm"].tap()
        
        sleep(1)
        
        XCTAssert(XCUIApplication().tables["uploadsList"].buttons["2min, ·, HIIT, \(randomString), LIVE"].isHittable)
        
    }

}
