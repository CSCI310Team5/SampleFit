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
        
        XCTAssertTrue(app.tables/*@START_MENU_TOKEN@*/.buttons["Profile Details"]/*[[".cells[\"Profile Details\"].buttons[\"Profile Details\"]",".buttons[\"Profile Details\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists)
        app.tables.buttons["Profile Details"].tap()
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    

    func testProfileView() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let app = XCUIApplication()
        
        XCTAssertTrue(app.staticTexts["Nickname"].exists)
        XCTAssertTrue(app.staticTexts["Date of Birth"].exists)
        XCTAssertTrue(app.staticTexts["Height"].exists)
        XCTAssertTrue(app.staticTexts["Weight"].exists)
        XCTAssertTrue(app.images[.localIdentifier(for: .profileAvatar)].exists)
    }
    
    func testNameEdit() throws{
        
        let app = XCUIApplication()
        let editButton = app.navigationBars["Profile Details"].buttons["Edit"]
        editButton.tap()
        let prev = app.staticTexts[.localIdentifier(for: .userNickname)]
        nameEdit(newName: "\(UUID().description.prefix(1))")
        
        app.buttons["Done"].tap()
        XCTAssertNotEqual(prev.label, app.staticTexts[.localIdentifier(for: .userNickname)].label)
    }
    
    func testNameEditCancel() throws{
        
        let app = XCUIApplication()
        let editButton = app.navigationBars["Profile Details"].buttons["Edit"]
        editButton.tap()
        let prev = app.staticTexts[.localIdentifier(for: .userNickname)]
        nameEdit(newName: "\(UUID().description.prefix(1))")
        app.buttons["Cancel"].tap()
        XCTAssertEqual(prev.label, app.staticTexts[.localIdentifier(for: .userNickname)].label)
    }
    
    
    
    func nameEdit(newName:String){
        let app = XCUIApplication()
        let textField = app.textFields["nicknameEdit"]
        textField.tap()
        textField.typeText(newName)
    }
    
    func testWeightEdit() throws{
        let app = XCUIApplication()
        let editButton = app.navigationBars["Profile Details"].buttons["Edit"]
        
        editButton.tap()
        let prev = app.staticTexts[.localIdentifier(for: .userWeight)]
        weightEdit(current: "\(app.staticTexts[.localIdentifier(for: .userWeight)].label)")
        app.buttons["Done"].tap()
        XCTAssertNotEqual(prev.label, app.staticTexts[.localIdentifier(for: .userWeight)].label)
    }
    
    func testWeightCancel() throws{
        let app = XCUIApplication()
        let editButton = app.navigationBars["Profile Details"].buttons["Edit"]
        
        editButton.tap()
        let prev = app.staticTexts[.localIdentifier(for: .userWeight)]
        weightEdit(current: "\(app.staticTexts[.localIdentifier(for: .userWeight)].label)")
        app.buttons["Cancel"].tap()
        XCTAssertEqual(prev.label, app.staticTexts[.localIdentifier(for: .userWeight)].label)
    }
    
    func weightEdit(current: String){
        let app = XCUIApplication()
        app.buttons["weightEditor"].tap()
        if current == "220 lb"{
            app.pickerWheels[current].swipeDown()
        }
        else{
            app.pickerWheels[current].swipeUp()}
    }
    
    
    func testHeightEdit() throws{
        let app = XCUIApplication()
        let editButton = app.navigationBars["Profile Details"].buttons["Edit"]
        
        editButton.tap()
        let prev = app.staticTexts[.localIdentifier(for: .userHeight)]
        HeightEdit(current: "\(app.staticTexts[.localIdentifier(for: .userHeight)].label)")
        app.buttons["Done"].tap()
        
        XCTAssertNotEqual(prev.label, app.staticTexts[.localIdentifier(for: .userHeight)].label)
    }
    
    func testHeightCancel() throws{
        let app = XCUIApplication()
        let editButton = app.navigationBars["Profile Details"].buttons["Edit"]
        
        editButton.tap()
        let prev = app.staticTexts[.localIdentifier(for: .userHeight)]
        HeightEdit(current: "\(app.staticTexts[.localIdentifier(for: .userHeight)].label)")
        app.buttons["Cancel"].tap()
        XCTAssertEqual(prev.label, app.staticTexts[.localIdentifier(for: .userHeight)].label)
    }
    
    func HeightEdit(current: String){
        let app = XCUIApplication()
        app.buttons["heightEditor"].tap()
        if current == "6' 8"{
            app.pickerWheels[current].swipeDown()
        }
        else{
            app.pickerWheels[current].swipeUp()}
    }
    
    
    func testBirthdayEdit() throws{
        let app = XCUIApplication()
        let editButton = app.navigationBars["Profile Details"].buttons["Edit"]

        editButton.tap()
        let prev = app.staticTexts[.localIdentifier(for: .userBirthday)].label
        
        birthdayEdit(current: "\(app.staticTexts[.localIdentifier(for: .userBirthday)].label)")
        app.buttons["Done"].tap()
        sleep(1)
    
        XCTAssertNotEqual(prev, app.staticTexts[.localIdentifier(for: .userBirthday)].label)
    }
    
    func testBirthdayCancel() throws{
        let app = XCUIApplication()
        let editButton = app.navigationBars["Profile Details"].buttons["Edit"]
        
        editButton.tap()
        let prev = app.staticTexts[.localIdentifier(for: .userBirthday)].label
        
        birthdayEdit(current: "\(app.staticTexts[.localIdentifier(for: .userBirthday)].label)")
        app.buttons["Cancel"].tap()
        sleep(1)
    
        XCTAssertEqual(prev, app.staticTexts[.localIdentifier(for: .userBirthday)].label)
    }
    
    func birthdayEdit(current: String){
        let app = XCUIApplication()
        app.datePickers.containing(.other, identifier:"Date Picker").element.tap()
        let collectionViewsQuery = app/*@START_MENU_TOKEN@*/.datePickers/*[[".otherElements[\"Preview\"].datePickers",".datePickers"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.collectionViews
        collectionViewsQuery.buttons.element.otherElements.containing(.staticText, identifier:"\(Int.random(in: 1...28))").element.tap()
        app.coordinate(withNormalizedOffset: CGVector(dx: 10, dy: 10)).tap()
        
    }
    
//    func avatarEdit(){
//
//        let app = XCUIApplication()
//        app.buttons["Edit"].tap()
//        app.scrollViews.otherElements.images.element.tap()
//        app.buttons["Cancel"].tap()
//        app.navigationBars["Profile Details"].buttons["Edit"].tap()
//        app.datePickers.containing(.other, identifier:"Date Picker").element.tap()
//    }
    
    
    
}
