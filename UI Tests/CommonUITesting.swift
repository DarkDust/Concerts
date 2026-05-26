//
//  CommonUITesting.swift
//  UITests
//
//  Created by Marc Haisenko on 2026-05-26.
//

import Foundation
import XCTest


/// Start the app for UI testing.
@MainActor
func startApp() -> XCUIApplication {
    let app = XCUIApplication()
    // Set environment variable to notify the app it's supposed to use mock data.
    app.launchEnvironment["UITesting"] = "true"
    app.launch()
    return app
}


/// Find a toolbar button, which is outside the "regular" UI hierarchy.
@MainActor
func findToolbarButton(identifier: String, in app: XCUIApplication) -> XCUIElement {
    let toolbarButtonPredicate = NSPredicate(
        format: "identifier == %@",
        identifier
    )
    
    return app.descendants(matching: .any)
        .matching(toolbarButtonPredicate)
        .firstMatch
}

