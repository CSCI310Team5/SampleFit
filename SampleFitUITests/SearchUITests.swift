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
        app.tabBars["Tab Bar"].buttons["Search"].tap()
    }

    override func tearDownWithError() throws {
    }

    func testSearchExerciseByCategory() throws {
        app.navigationBars["Search"].searchFields["Videos, Users"].tap()
        app.scrollViews.otherElements.buttons["HIIT"].tap()
        
        sleep(1)
        XCTAssert(app.tables.buttons["·, HIIT, HIIT with Jessie"].isHittable)
    }
    
    func testSearchExerciseByKeyword() throws {
        let searchNavigationBar = app.navigationBars["Search"]
        searchNavigationBar.searchFields["Videos, Users"].tap()
        
        app.keyboards.keys["j"].tap()
        app.keyboards.keys["e"].tap()
        app.keyboards.keys["s"].tap()
        app.keyboards.keys["s"].tap()
        app.keyboards.keys["i"].tap()
        app.keyboards.keys["e"].tap()

        app/*@START_MENU_TOKEN@*/.buttons["search"]/*[[".keyboards",".buttons[\"search\"]",".buttons[\"Search\"]"],[[[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        
        let tablesQuery = app.tables
        XCTAssert(tablesQuery/*@START_MENU_TOKEN@*/.buttons["·, Push up, Pushup with Jessie"]/*[[".cells[\"·, Push up, Pushup with Jessie\"]",".buttons[\"·, Push up, Pushup with Jessie\"]",".buttons[\"exerciseName\"]"],[[[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.isHittable)
        XCTAssert(tablesQuery/*@START_MENU_TOKEN@*/.buttons["·, HIIT, HIIT with Jessie"]/*[[".cells[\"·, HIIT, HIIT with Jessie\"]",".buttons[\"·, HIIT, HIIT with Jessie\"]",".buttons[\"exerciseName\"]"],[[[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.isHittable)
        XCTAssert(tablesQuery/*@START_MENU_TOKEN@*/.buttons["·, Cycling, Cycling with Jessie"]/*[[".cells[\"·, Cycling, Cycling with Jessie\"]",".buttons[\"·, Cycling, Cycling with Jessie\"]",".buttons[\"exerciseName\"]"],[[[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.isHittable)
    }
    
    func testSearchUserAndToggleFollowUser() throws {
        
        let searchNavigationBar = app.navigationBars["Search"]
        searchNavigationBar.searchFields["Videos, Users"].tap()
        searchNavigationBar/*@START_MENU_TOKEN@*/.segmentedControls["scopeBar"].buttons["User"]/*[[".segmentedControls[\"scopeBar\"].buttons[\"User\"]",".buttons[\"User\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()
        
        let zKey = app/*@START_MENU_TOKEN@*/.keyboards.keys["z"]/*[[".keyboards.keys[\"z\"]",".keys[\"z\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/
        zKey.tap()
        app/*@START_MENU_TOKEN@*/.keys["i"]/*[[".keyboards.keys[\"i\"]",".keys[\"i\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let hKey = app/*@START_MENU_TOKEN@*/.keys["h"]/*[[".keyboards.keys[\"h\"]",".keys[\"h\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        hKey.tap()
        let aKey = app/*@START_MENU_TOKEN@*/.keys["a"]/*[[".keyboards.keys[\"a\"]",".keys[\"a\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        aKey.tap()
        let nKey = app/*@START_MENU_TOKEN@*/.keys["n"]/*[[".keyboards.keys[\"n\"]",".keys[\"n\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        nKey.tap()
        app/*@START_MENU_TOKEN@*/.buttons["search"]/*[[".keyboards",".buttons[\"search\"]",".buttons[\"Search\"]"],[[[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        
        sleep(1)
        XCTAssert(app.scrollViews.otherElements.buttons["zihanqi@usc.edu, (iOS God)"].isHittable)
        app.scrollViews.otherElements.buttons["zihanqi@usc.edu, (iOS God)"].tap()
        
        app.buttons["FOLLOW"].tap()
        app.tabBars["Tab Bar"].buttons["Me"].tap()
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["Following"]/*[[".cells[\"Following\"].buttons[\"Following\"]",".buttons[\"Following\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        XCTAssert(tablesQuery/*@START_MENU_TOKEN@*/.buttons["zihanqi@usc.edu, (iOS God)"]/*[[".cells[\"zihanqi@usc.edu, (iOS God)\"].buttons[\"zihanqi@usc.edu, (iOS God)\"]",".buttons[\"zihanqi@usc.edu, (iOS God)\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.isHittable)
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["zihanqi@usc.edu, (iOS God)"]/*[[".cells[\"zihanqi@usc.edu, (iOS God)\"].buttons[\"zihanqi@usc.edu, (iOS God)\"]",".buttons[\"zihanqi@usc.edu, (iOS God)\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["FOLLOWED"].tap()
        app.navigationBars["zihanqi@usc.edu"].buttons["Following"].tap()
        
        XCTAssertFalse(tablesQuery/*@START_MENU_TOKEN@*/.buttons["zihanqi@usc.edu, (iOS God)"]/*[[".cells[\"zihanqi@usc.edu, (iOS God)\"].buttons[\"zihanqi@usc.edu, (iOS God)\"]",".buttons[\"zihanqi@usc.edu, (iOS God)\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.isHittable)
        
    }

}
