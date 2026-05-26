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
    func testExample() throws {
        let app = startApp()
        
        let itemBeforeClick = findItem(in: app)
        XCTAssertFalse(itemBeforeClick.exists)

        let addItem = findToolbarButton(identifier: "add-item", in: app)
        XCTAssertTrue(addItem.waitForExistence(timeout: 2))
        addItem.click()
        
        let itemAfterClick = findItem(in: app)
        XCTAssertTrue(itemAfterClick.exists)
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

