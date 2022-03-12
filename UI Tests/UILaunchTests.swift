//
//  UI_TestsLaunchTests.swift
//  UI Tests
//
//  Created by Piper McCorkle on 3/10/22.
//

import XCTest

class UILaunchTests: XCTestCase {
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testVehicle() throws {
        let app = XCUIApplication()
        app.launch()
        if !app.tables.buttons["The Mazda CX-5"].exists {
            app.navigationBars["Vehicles"].buttons["Add Fixtures"].tap()
        }
        app.tables.buttons["The Mazda CX-5"].tap()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Vehicle"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
