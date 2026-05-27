//
//  ConcertsUITests.swift
//  ConcertsUITests
//
//  Created by Marc Haisenko on 2026-05-26.
//

import XCTest

final
class ConcertsUITests: XCTestCase {

    override
    func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override
    func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testAddPerformance() throws {
        let app = startApp()
        
        // Verify row are missing in table
        XCTAssertFalse(app.staticTexts["Some Band"].waitForExistence(timeout: 1))
        XCTAssertFalse(app.staticTexts["Awesome Venue"].waitForExistence(timeout: 1))
        
        // Open add sheet
        let addButton = findToolbarButton(identifier: "add-item", in: app)
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
        addButton.click()
        
        // Fill out form
        let bandNameField = app.textFields["band-name"]
        XCTAssertTrue(bandNameField.waitForExistence(timeout: 2))
        bandNameField.click()
        bandNameField.typeText("Some Band")
        
        let venueNameField = app.textFields["venue-name"]
        XCTAssertTrue(venueNameField.waitForExistence(timeout: 2))
        venueNameField.click()
        venueNameField.typeText("Awesome Venue")
        
        // Confirm add
        let confirmButton = app.buttons["Add"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 2))
        confirmButton.click()
        
        // Verify row exists in table
        XCTAssertTrue(app.staticTexts["Some Band"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Awesome Venue"].waitForExistence(timeout: 2))
    }

}


private
extension ConcertsUITests {
    
    @MainActor
    func findItem(in app: XCUIApplication) -> XCUIElement {
        let predicate = NSPredicate(format: "identifier BEGINSWITH %@", "item-")
        return app.buttons.matching(predicate).firstMatch
    }
    
}

