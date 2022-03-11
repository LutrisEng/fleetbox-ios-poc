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
        if !app.tables/*@START_MENU_TOKEN@*/.buttons["The Mazda CX-5"]/*[[".cells[\"The Mazda CX-5\"].buttons[\"The Mazda CX-5\"]",".buttons[\"The Mazda CX-5\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists {
            app.navigationBars["Vehicles"].buttons["Add Fixtures"].tap()
        }
        app.tables/*@START_MENU_TOKEN@*/.buttons["The Mazda CX-5"]/*[[".cells[\"The Mazda CX-5\"].buttons[\"The Mazda CX-5\"]",".buttons[\"The Mazda CX-5\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Vehicle"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testLogItem() throws {
        let app = XCUIApplication()
        app.launch()
        if !app.tables/*@START_MENU_TOKEN@*/.buttons["The Mazda CX-5"]/*[[".cells[\"The Mazda CX-5\"].buttons[\"The Mazda CX-5\"]",".buttons[\"The Mazda CX-5\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists {
            app.navigationBars["Vehicles"].buttons["Add Fixtures"].tap()
        }
        app.tables/*@START_MENU_TOKEN@*/.buttons["The Mazda CX-5"]/*[[".cells[\"The Mazda CX-5\"].buttons[\"The Mazda CX-5\"]",".buttons[\"The Mazda CX-5\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let predicate = NSPredicate(format: "label CONTAINS 'Vehicle manufactured'")
        let button = app.tables.buttons.containing(predicate).element
        while !button.isHittable {
            app.scrollViews.element(boundBy: 0).swipeUp()
        }
        button.tap()
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Log Item"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
